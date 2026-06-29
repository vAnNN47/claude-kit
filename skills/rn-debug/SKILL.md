---
name: rn-debug
description: Systematically diagnose a React Native / Expo render bug — blank screen, content missing, or behavior that differs between Android and iOS — without thrashing. Enforces isolation (binary search + colored backgrounds), one hypothesis at a time, a known-good baseline, and reading logs first. Trigger on "blank screen", "screen not rendering", "works on iOS but not Android" (or vice versa), "nothing shows up", "/rn-debug", or any RN layout/render mystery.
---

# rn-debug — diagnose RN render bugs without thrashing

A screen renders on one platform and not the other (classically: fine iOS, blank
Android). The failure mode is not the bug — it's **thrashing**: sprinkling dummy text,
fixing then re-breaking, changing many things at once. This skill forbids that.

## Anti-thrash rules (follow strictly)

1. **Read logs before guessing.** Check Metro output and `adb logcat` (Android) for a
   swallowed JS/native error. Hermes hides some errors that JSC tolerates. A blank
   screen is often a caught exception, not a layout problem.
2. **One hypothesis at a time.** Change exactly one thing, observe, record result.
3. **Keep a known-good baseline.** Commit or stash the last working state. If a change
   makes it worse, **revert immediately** — never stack edits on a broken tree.
4. **Probe with color, not text.** Set `backgroundColor: 'red'` on a suspect view. If
   red shows → the view has size, problem is content/children. If no red → the view is
   collapsed/unmounted (layout/height problem). Dummy text can't tell these apart.
5. **Binary-search the tree.** Comment out half the screen's children; see if the rest
   renders. Halve again toward the offending node. Don't eyeball — bisect.

## Diagnostic order (cheapest/most-likely first)

1. **Logs** — Metro + `adb logcat *:E` (or `npx react-native log-android`). Fix any error found.
2. **Is it mounted?** Add a top-level `<View style={{flex:1, backgroundColor:'red'}}/>`
   as the screen's only child. No red on Android → root has no height → walk up adding
   `flex: 1` to each parent (screen container, navigator wrapper).
3. **Height/flex collapse** (most common Android-only blank): every container that
   should fill needs `flex: 1` up to the root; `ScrollView` content needs
   `contentContainerStyle={{flexGrow:1}}`; absolute children need a sized parent.
4. **Reanimated/worklets** — if the screen uses `react-native-reanimated`, temporarily
   replace `Animated.*` with plain `View`/styles. If it renders → worklet/animated-style
   issue (check babel plugin order: reanimated plugin LAST; check worklet directives).
5. **Clipping** — `overflow:'hidden'`, `elevation`, `zIndex`, transforms behave
   differently on Android; remove temporarily to isolate.
6. **SafeArea** — wrong `SafeAreaView` import or 0-height inset; swap to
   `react-native-safe-area-context` and confirm provider is mounted.
7. **Content invisible vs absent** — text same color as background? image with no
   dimensions? Use the color probe to decide.

## Known Issues

Catalogued real-world root causes — the portable RN/Expo **mega-bug registry**. Scope is broader than
render bugs: inputs/caret, keyboard scroll, bottom sheets, reanimated lint, @expo/ui, NativeWind/
react-native-css, a11y, and native modules. If symptoms match, jump straight here — but still
**reproduce + prove** (color probe / dump / on-device screenshot) before claiming the fix. Each entry
carries `Versions seen on` + `Search terms/upstream` so `/refinery` (planned) can re-check whether a
newer version already fixed it before you re-apply a workaround.

- **Render / blank screen:** KI-1 (RefreshControl wrapper), KI-2 (RTL #16206 scroll death).
- **Inputs:** KI-3 (controlled-caret), KI-7 (sheet TextInput), KI-17 (store re-render storm).
- **Keyboard / scroll:** KI-4 (mode=layout), KI-5 (modal presentation).
- **Bottom sheets:** KI-6 (height cap / escalate), KI-7, KI-9 (@expo/ui picker).
- **Animation:** KI-8 (reanimated immutability lint).
- **Styling (NativeWind/react-native-css):** KI-14 (light-dark drop), KI-15 (rem spacing), KI-16 (SDK-56 deps).
- **Accessibility:** KI-10 (icon label), KI-11 (announce), KI-12 (font clamp).
- **Native modules:** KI-13 (dev-client rebuild).

### KI-1 · A custom-component `refreshControl` makes a `ScrollView` mount ZERO children (Android only)

- **Symptom:** Screen renders header + tab bar, but the `ScrollView` body is **empty —
  children are absent, not invisible** (an inline `backgroundColor:'red'` child inside the
  ScrollView does NOT paint; the same probe *outside* the ScrollView does). No crash, no
  redbox, no logcat error. **iOS renders fine** (lenient).
- **Root cause:** the `refreshControl` prop was given a **custom wrapper component** (e.g.
  `refreshControl={<RefreshSpinner .../>}`, where `RefreshSpinner` returns a `<RefreshControl>`)
  instead of a **direct `<RefreshControl>` element**. RN's Android `ScrollView` special-cases /
  clones the `refreshControl` child and expects it to *be* a `RefreshControl`; a wrapper breaks
  that and the ScrollView renders none of its children. On New Architecture (Fabric) this is
  silent (no error); iOS tolerates it.
- **Fix (one line):** pass a direct element, lift the refreshing state into the screen:
  ```tsx
  const [refreshing, setRefreshing] = useState(false);
  const onRefresh = async () => { setRefreshing(true); try { await refresh(); } finally { setRefreshing(false); } };
  // ...
  <ScrollView refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={c} colors={[c]} />}>
  ```
  Works on BOTH a raw RN `ScrollView` and a react-native-css (`useCssElement`) `@/tw` `ScrollView`.
- **NOT the cause (ruled out by bisect, each proven with an on-device screenshot):** the
  react-native-css / NativeWind `@/tw` wrapper (innocent — same blank with a raw RN ScrollView,
  and renders fine once the refreshControl is a direct element); `style` vs `className` for
  `flex-1`; flex/height collapse; color tokens (other tabs render fine); reanimated worklets/babel
  (other screens use `useSharedValue`/`useAnimatedStyle` fine); a plain JS `onScroll` +
  `scrollEventThrottle` (fine once the refreshControl is direct).
- **Versions seen on:** Expo SDK `56.0.12` · React Native `0.85.3` · React `19.2.3` ·
  New Architecture (Fabric) **enabled** · `react-native-css` `3.0.1` ·
  `nativewind` `5.0.0-preview.4` · `react-native-reanimated` `4.3.1` ·
  `react-native-worklets` `0.8.3` · `react-native-gesture-handler` `2.31.1` ·
  `react-native-safe-area-context` `5.7.0`.
- **Objects/APIs involved:** `ScrollView`, `RefreshControl`, `refreshControl` prop (must be a
  direct `<RefreshControl>`, not a wrapper component), `onScroll`, `scrollEventThrottle`.
- **Search terms / upstream:** "RefreshControl prevents ScrollView rendering children Android",
  gesture-handler [#2227], [#1067]; reanimated [#5972] (`useAnimatedScrollHandler` + `refreshControl`
  Android).
- **Fast on-device proof (no asking the user):** `adb exec-out screencap` / `adb shell screencap
  -p && adb pull` to SEE the screen; `adb shell uiautomator dump` to read the actual node tree
  (absent children = only header/tab text nodes present). Bisect props by editing + re-screencap.
  Bisect with an inline red probe OUTSIDE vs INSIDE the ScrollView to prove children-absent.

### KI-2 · RTL-only: a single-line `TextInput` with `textAlign:"right"` kills ScrollView scroll on Android

- **Symptom:** A form scrolls fine in **LTR/English** but in **RTL/Hebrew the ScrollView won't scroll**
  on Android (and the scroll indicator is missing — no scroll, no scrollbar). iOS scrolls fine in
  both. Often pinned to *one* screen that has a text field.
- **Root cause:** **React Native bug [#16206](https://github.com/facebook/react-native/issues/16206)** —
  a **single-line** `TextInput` whose `textAlign` is `"right"` (or `"center"`) inside a `ScrollView`
  blocks scrolling on **Android**. RTL flips inputs to `textAlign:"right"`, so the bug only shows in
  RTL. LTR uses `textAlign:"left"` → no bug. **`multiline` TextInputs are immune** (multiline is the
  documented workaround), so a multiline field on the same screen scrolls — which misleads you.
- **The platforms disagree on the fix — it MUST be platform-split:**
  - **Android:** drop `textAlign`, set **`writingDirection:"rtl"` only** (right-aligns text + placeholder
    there *and* dodges #16206).
  - **iOS:** keep `textAlign:"right"` — iOS needs it (with `writingDirection` alone the placeholder
    sticks **left**) and iOS has no such scroll bug.
  ```tsx
  // single-line input inside a ScrollView, RTL-aware:
  style={Platform.OS === "android" ? { writingDirection } : { textAlign: "right", writingDirection }}
  ```
  Multiline inputs can keep `textAlign` on both platforms (immune).
- **Ruled out (each by on-device screenshot, RTL vs LTR):** keyboard-controller version (no RTL fix in
  the changelog), `mode`/`flex`/`persistentScrollbar`, the scrollbar being a cosmetic Android-RTL quirk
  (it's not — scroll is genuinely dead, the missing bar is a *symptom*).
- **Search terms:** RN #16206 "scrolling TextInput in ScrollView textAlign right center android",
  textAlign right ScrollView not scrolling RTL, writingDirection vs textAlign placeholder iOS RTL.
- **Fast proof:** flip the app to the RTL locale, try to scroll → dead; switch the offending field to
  the platform-split style → scrolls. `adb shell uiautomator dump` shows the content is present (just
  unscrollable).

### KI-3 · iOS caret jumps backwards on fast typing in a controlled `TextInput`

- **Symptom:** On iOS, typing fast into a `TextInput` makes the **caret jump backwards** / characters
  land out of order. Android fine.
- **Root cause:** the field is **controlled** (`value` from `useState`). Each keystroke re-renders the
  parent and feeds a one-keystroke-**stale** `value` back to the input, so the OS caret fights the
  state. A store subscription without a selector amplifies it (re-render storm — see KI-9-perf).
- **Fix:** make free-text fields **uncontrolled** — `defaultValue` + a `ref`, read the value only at
  save. `defaultValue` must read a plain initial value, never `ref.current` (satisfies
  `react-hooks/refs`). If the field is reused across opens, `ref.current?.clear()` on present.
- **Search terms:** "React Native TextInput cursor jumps to beginning controlled value iOS",
  controlled vs uncontrolled TextInput caret.

### KI-4 · Android: keyboard-controller `mode="insets"` traps content behind the keyboard

- **Symptom:** Android — when the keyboard opens, content stays **trapped behind it** and the scroll
  range never extends to reach the focused field. iOS fine.
- **Root cause:** `react-native-keyboard-controller` 1.21.x default **`mode="insets"`** is broken on
  Android (lib **#1394**): its internal contentInset/clipping doesn't extend the scroll range.
- **Fix:** `KeyboardAwareScrollView` **`mode="layout"`** (appends a real spacer view → genuine scroll
  range) + `style={{ flex: 1 }}` on the scroll + `scrollEnabled={false}` on any multiline field so it
  auto-grows. `flex:1` **alone does NOT fix it**. Caveat: dragging *on* a multiline textarea still
  won't scroll the page on Android (multiline grabs the vertical drag) — scroll from elsewhere works.
- **Versions seen on:** keyboard-controller 1.21.x · Expo SDK 56 · RN 0.85. **Search:** keyboard-controller #1394 insets vs layout Android.

### KI-5 · Android: a `modal`-presentation screen's keyboard scroll is dead

- **Symptom:** A screen pushed with `presentation: "modal"` won't keyboard-scroll on Android even with
  KI-4 applied; iOS fine.
- **Root cause:** on Android an RN `modal` is a **separate window** the root `<KeyboardProvider>`'s
  events never reach.
- **Fix:** use **`presentation: "card"`** for the route, OR wrap the screen in its own nested
  `<KeyboardProvider>`. **Search:** keyboard-controller modal presentation Android KeyboardProvider.

### KI-6 · Bottom sheet grows under the status bar / can't scroll to top fields

- **Symptom:** A bottom-anchored sheet with several inputs **overshoots the status bar**, drag is
  janky, top fields unreachable — worst on older Android.
- **Root cause:** bottom-anchored sheets have **no height cap**; tall/scrolly content has nowhere to go.
- **Fix:** for brief content, cap the sheet (an opt-in `scrollable` that caps the body below the top
  inset + scrolls, grabber-only drag). For forms (many inputs / >~1 screen / long text), **escalate to
  a full-screen modal** — Material 3 / HIG: sheets are for brief tasks only. Rule: simple/few fields →
  sheet; complex → full modal screen. **Search:** bottom sheet status bar overshoot Android, M3 sheet guidance.

### KI-7 · `TextInput` inside a bottom sheet flashes the keyboard / fights the drag

- **Symptom:** Focusing a raw RN `TextInput` inside a keyboard-aware sheet flickers the keyboard and
  the input fights the sheet's pan gesture.
- **Fix:** use the sheet package's dedicated **`SheetTextInput`** (keyboard-aware, gesture-coordinated),
  never a bare RN `TextInput`, inside the sheet body. **Search:** bottom sheet TextInput keyboard flicker gesture.

### KI-8 · reanimated lint `react-hooks/immutability`: "value passed as a hook argument cannot be modified"

- **Symptom:** ESLint errors on `sharedValue.value = …` written inside a **`useCallback`** (commonly
  `useFocusEffect(useCallback(...))`).
- **Root cause:** the shared value is a `useCallback` dependency; mutating it there violates the rule.
- **Fix:** mutate the shared value inside a **`useEffect`** or an **event handler** instead. For
  per-focus work use `navigation.addListener("focus", run)` inside a `useEffect` (+ one mount `run()`),
  not `useFocusEffect(useCallback(...))`. **Search:** react-hooks immutability reanimated shared value useCallback.

### KI-9 · @expo/ui compact `DateTimePicker` shows a red artifact / "pushed too far right" in RTL

- **Symptom:** the compact (`@expo/ui`) `DateTimePicker` paints a red artifact / trailing dead-space,
  "clock pushed too far right", in RTL.
- **Root cause:** the compact picker sizes its **width from `style`, not its content**
  (`matchContents` only does vertical). A wrapper frame wider than the time pill leaves trailing space
  the native control fills with an artifact; in RTL the pill is leading-aligned (right) so it shows.
- **Fix:** **no wrapper frame** — snug `style={{ width: 84, height: 44 }}` (84 = 24h content width,
  44 = min touch target). `matchContents.horizontal` can't be injected through the wrapper.
- **Search:** @expo/ui DateTimePicker compact width RTL artifact matchContents.

### KI-10 · a11y: icon-only control reads as a junk glyph (or says nothing)

- **Symptom:** VoiceOver/TalkBack reads an icon-only/icon+text `Pressable` as a garbage string (the
  `@expo/vector-icons` glyph name) or stays silent.
- **Fix:** `accessibilityRole="button"` + `accessibilityLabel` on the control; `accessible={false}` on
  decorative icons. A `Pressable` whose child is plain `<Text>` is already read — don't double-label.
  Note: React Navigation injects role/label into `tabBarButton` props, so spread them, don't re-label.
- **Search:** React Native accessibilityLabel icon button VoiceOver reads glyph.

### KI-11 · a11y: Toast / dynamically-shown content is never announced

- **Symptom:** a Toast or other view that appears after an action is not announced by the screen reader.
- **Fix:** RN doesn't auto-announce new views — call
  **`AccessibilityInfo.announceForAccessibility(msg)`** on show + set
  `accessibilityLiveRegion="polite"` on the container. **Search:** RN announceForAccessibility live region toast.

### KI-12 · a11y: large OS font shatters fixed layouts (clipped rows, text under status bar)

- **Symptom:** at large OS font sizes, fixed-height rows clip and text collides with the status bar.
- **Fix:** clamp text scaling — default `maxFontSizeMultiplier` (e.g. **1.4**) on the app's shared
  `Text` wrapper so it applies app-wide. Also: compute color contrast against the actual `bg`/`card`
  **per theme** (a light-mode muted gray that passes nowhere near AA must be darkened). **Search:** RN maxFontSizeMultiplier Dynamic Type clamp.

### KI-13 · Native module: `Cannot find native module 'ExpoXxx'` in dev, works in release

- **Symptom:** a native dep throws `Cannot find native module 'ExpoXxx'` on a dev/Metro reload but the
  release build is fine.
- **Root cause:** the native dep was added but the **dev client wasn't recompiled** — expected, not a
  code bug.
- **Fix:** **rebuild the dev client** (`eas build --profile development` iOS / `npm run android`). For
  graceful degradation, **lazy-`import()` + `try/catch`** the module so a Metro-only reload doesn't
  crash. **Search:** Expo "Cannot find native module" dev client rebuild.

### KI-14 · NativeWind / react-native-css: themed `bg-*` render EMPTY when colors use `light-dark()`

- **Symptom:** every themed `bg-*` / color renders empty (no fill). Easy to misread as one color
  "not painting" when a dark UI just hides the missing fills.
- **Root cause:** metro runs react-native-css with **`inlineVariables:false`** (kept on purpose so
  `var()` stays PlatformColor-safe), and in that mode it **drops the dark branch of `light-dark()`**.
- **Fix / rule:** **never use `light-dark()`** for theme colors. Put the light palette in `@theme` and
  override the same `--color-*` vars in an `@media (prefers-color-scheme: dark)` block — both branches
  survive. **Search:** react-native-css inlineVariables light-dark drops dark, NativeWind v5 theme var media query.

### KI-15 · NativeWind / react-native-css: every `p-/m-/gap-/w-/h-` is ~12% too small

- **Symptom:** spacing looks cramped/broken on dense screens; `p-4` isn't 16px.
- **Root cause:** react-native-css defaults **rem to 14px**, so Tailwind's `0.25rem` step renders
  **3.5px not 4** — silently shrinking the whole spacing scale ~12%.
- **Fix:** pin **`--spacing: 4px`** in `global.css` so the scale snaps to 4/8/12/16 (`p-4`==16,
  `w-8`==32). **Radii stay rem-based** → use named (`rounded-card`) or arbitrary (`rounded-[12px]`),
  never `rounded-xl`. **Search:** react-native-css rem 14px spacing, NativeWind --spacing pin.

### KI-16 · The `expo-tailwind-setup` skill pins Expo-54 dep versions (wrong on SDK 56)

- **Symptom:** following `expo:expo-tailwind-setup` installs `react-native-css@0.0.0-nightly…` /
  `nativewind@…preview.2`, which peer on **Expo 54** and break on SDK 56.
- **Fix (SDK 56-correct deps):** `nativewind@5.0.0-preview.4`, `react-native-css@^3.0.1`,
  `tailwindcss@^4`, `@tailwindcss/postcss`, `tailwind-merge`, `clsx`; `overrides.lightningcss=1.30.1`.
  Tailwind v4 is CSS-first → no `tailwind.config.js`, no `babel.config.js`. **Search:** nativewind v5 expo sdk 56 versions.

### KI-17 · Zustand: bare `useStore()` re-renders ALL screens on any `set()`

- **Symptom:** unrelated screens re-render on every store write (theme toggle, locale, another tab's
  write); fed an input-caret bug (KI-3) and general jank.
- **Root cause:** expo-router keeps every tab **mounted**, so a no-selector store subscription
  (`const s = useStore()`) re-renders all of them on ANY `set()`.
- **Fix:** always subscribe via a **`useShallow` selector** that picks only what the screen needs;
  `useMemo` heavy derived series on their real inputs. **Search:** zustand useShallow selector avoid re-render, expo-router tabs stay mounted.

## Output

State: the platform divergence, the **single confirmed root cause** (with the evidence
that proved it — log line, color probe result, or the bisect step), and the minimal fix.
Do not claim a fix without reproducing the failure and then the success on the failing
platform.
