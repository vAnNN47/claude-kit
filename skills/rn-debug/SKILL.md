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

Catalogued real-world root causes. If symptoms match, jump straight here — but still
**reproduce + prove** (color probe / dump) before claiming the fix.

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

## Output

State: the platform divergence, the **single confirmed root cause** (with the evidence
that proved it — log line, color probe result, or the bisect step), and the minimal fix.
Do not claim a fix without reproducing the failure and then the success on the failing
platform.
