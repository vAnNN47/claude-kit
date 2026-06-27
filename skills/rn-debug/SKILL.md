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

## Output

State: the platform divergence, the **single confirmed root cause** (with the evidence
that proved it — log line, color probe result, or the bisect step), and the minimal fix.
Do not claim a fix without reproducing the failure and then the success on the failing
platform.
