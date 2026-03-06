# Character Selection iOS Layout Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the character selection screen on iOS so the header, back button, and continue button are fully visible, and apply compact visual tweaks for iPhone in two-player mode.

**Architecture:** All changes are isolated to `CharacterSelectionView.swift`. A universal `.safeAreaPadding()` fix corrects the layout offset caused by `MenuBackgroundView`'s `ignoresSafeArea()` expanding the ZStack to full-screen coordinates. A `horizontalSizeClass` guard applies compact sizing/spacing only when on iPhone (`compact`) in two-player mode; iPad and macOS keep original values.

**Tech Stack:** SwiftUI, `horizontalSizeClass` environment value (iOS 15+), `.safeAreaPadding()` (iOS 17+)

---

### Task 1: Add safe area padding (universal fix)

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`

**Context:**
`MenuBackgroundView` calls `.ignoresSafeArea()` on its children. This causes the parent `ZStack` in `CharacterSelectionView` to expand to full-screen coordinates, so all content starts at y=0 (behind the Dynamic Island / status bar). Adding `.safeAreaPadding()` to both the content `VStack` and the back button overlay `VStack` pushes them into the visible safe area.

**Step 1: Open the file and locate the two VStacks inside the ZStack**

`FlappyBird/Views/CharacterSelectionView.swift` lines 15–56. There are two direct children of the `ZStack` that need `.safeAreaPadding()`:
1. The content `VStack` (line 15) — ends with `.padding()` on line 46
2. The back button overlay `VStack` (line 49) — no padding modifier on the outer VStack itself

**Step 2: Add `.safeAreaPadding()` to the content VStack**

Change:
```swift
            VStack(spacing: 20) {
                // ...
            }
            .padding()
```
To:
```swift
            VStack(spacing: 20) {
                // ...
            }
            .padding()
            .safeAreaPadding()
```

**Step 3: Add `.safeAreaPadding(.top)` to the back button overlay VStack**

Change:
```swift
            // Back button
            VStack {
                HStack {
                    BackButton { router.goBackToTitle() }
                    Spacer()
                }
                .padding()
                Spacer()
            }
```
To:
```swift
            // Back button
            VStack {
                HStack {
                    BackButton { router.goBackToTitle() }
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .safeAreaPadding(.top)
```

**Step 4: Build and run on iPhone 16 Pro simulator**

Expected: header "Select Characters", back arrow, and "Continue" button all fully visible within the screen bounds. No clipping at top or bottom.

**Step 5: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "fix: apply safeAreaPadding to CharacterSelectionView to fix iOS layout offset"
```

---

### Task 2: Add horizontalSizeClass environment value and compact layout properties

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`

**Context:**
`@Environment(\.horizontalSizeClass)` returns `.compact` on iPhone and `.regular` on iPad/Mac. Combined with `router.config.playerCount`, this gates all compact tweaks to iPhone two-player mode only.

**Step 1: Add the environment property below the existing `@State` declarations**

Current state declarations end at line 9. Add after line 9:
```swift
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
```

**Step 2: Add a computed property for the compact 2P condition**

Add immediately after the environment property:
```swift
    private var isCompact2P: Bool {
        horizontalSizeClass == .compact && router.config.playerCount == 2
    }
```

**Step 3: Build to confirm it compiles**

Expected: no errors.

**Step 4: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: add horizontalSizeClass and isCompact2P computed property"
```

---

### Task 3: Apply compact spacing and typography

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`

**Context:**
Swap the three values that affect vertical spacing and text size when `isCompact2P` is true. Each is a one-liner ternary replacement.

**Step 1: Update the outer VStack spacing**

Change:
```swift
            VStack(spacing: 20) {
```
To:
```swift
            VStack(spacing: isCompact2P ? 12 : 20) {
```

**Step 2: Update the "Select Characters" font size**

Change:
```swift
                    .font(.system(size: 36, weight: .bold, design: .rounded))
```
To:
```swift
                    .font(.system(size: isCompact2P ? 28 : 36, weight: .bold, design: .rounded))
```

**Step 3: Build and run on iPhone 16 Pro simulator in two-player mode**

Expected: tighter spacing between header and pickers, slightly smaller header text.

**Step 4: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: compact VStack spacing and header font for iPhone 2P mode"
```

---

### Task 4: Apply compact picker typography and card size

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`

**Context:**
`characterPicker` and `characterCard` are private functions. Pass `isCompact2P` into them via new parameters so they can adapt their font and frame. Do not change any existing call sites on iPad/Mac paths.

**Step 1: Update the `characterPicker` function signature and internals**

Current signature:
```swift
    private func characterPicker(title: String, selection: Binding<GameCharacter>) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
```

New signature and internals:
```swift
    private func characterPicker(title: String, selection: Binding<GameCharacter>, compact: Bool = false) -> some View {
        VStack(spacing: compact ? 8 : 12) {
            Text(title)
                .font(compact ? .footnote.bold() : .title3.bold())
```

**Step 2: Update the `characterCard` call inside `characterPicker` to pass the card size**

Inside `characterPicker`, the call to `characterCard` currently passes `character` and `isSelected`. Add a `size` parameter:

Change:
```swift
                    characterCard(character: character, isSelected: selection.wrappedValue == character)
```
To:
```swift
                    characterCard(character: character, isSelected: selection.wrappedValue == character, size: compact ? 84 : 100)
```

**Step 3: Update `characterCard` to accept and use the size parameter**

Current signature and frame:
```swift
    private func characterCard(character: GameCharacter, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            // ...
        }
        .frame(width: 100, height: 100)
```

New signature and frame:
```swift
    private func characterCard(character: GameCharacter, isSelected: Bool, size: CGFloat = 100) -> some View {
        VStack(spacing: 6) {
            // ...
        }
        .frame(width: size, height: size)
```

**Step 4: Update the call sites in `body` to pass `compact: isCompact2P`**

In the two-player branch:
```swift
                    HStack(spacing: 30) {
                        characterPicker(title: "Player 1", selection: $player1Selection, compact: isCompact2P)
                        Divider().frame(height: 300)
                        characterPicker(title: "Player 2", selection: $player2Selection, compact: isCompact2P)
                    }
```

In the single-player branch (no change needed — `compact` defaults to `false`):
```swift
                    characterPicker(title: "Player 1", selection: $player1Selection)
```

**Step 5: Build and run on iPhone 16 Pro simulator in two-player mode**

Expected: "Player 1" / "Player 2" labels are smaller, cards are 84×84pt, grid spacing is tighter.

**Step 6: Also verify on iPad simulator**

Expected: no visual change from before — labels still `.title3.bold()`, cards still 100×100pt.

**Step 7: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: compact picker font and 84pt cards for iPhone 2P mode"
```

---

### Task 5: Apply compact Continue button styling

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`

**Context:**
`GlassButtonStyle` sets both the font and frame height via hardcoded `.font(.title2.bold())` and `.frame(width: 200, height: 50)`. However, `TitleView.swift` also uses `GlassButtonStyle` for its "1 Player" and "2 Players" buttons without setting its own font/height. Modifying `GlassButtonStyle` would break those buttons.

The safe approach: set `.font()` and `.frame(height:)` directly on the `Text("Continue")` label inside the button. A font applied to the label's `Text` takes precedence over the style's font on `configuration.label`, so we get the override we need without touching `GlassButtonStyle` or any other call sites.

**Step 1: Update the Continue button label**

Change:
```swift
                Button {
                    // ...
                } label: {
                    Text("Continue")
                }
                .buttonStyle(GlassButtonStyle(accentColor: .green))
```
To:
```swift
                Button {
                    // ...
                } label: {
                    Text("Continue")
                        .font(isCompact2P ? .headline.bold() : .title2.bold())
                        .frame(height: isCompact2P ? 44 : 50)
                }
                .buttonStyle(GlassButtonStyle(accentColor: .green))
```

**Step 2: Build and run on iPhone 16 Pro simulator in two-player mode**

Expected: "Continue" text is smaller, button is 44pt tall. Verify the button still looks correct (glass background, green text, shadow).

**Step 3: Also verify on iPad, single-player mode, and the title screen**

Expected: "Continue" uses `.title2.bold()` and is 50pt tall — identical to before. Title screen "1 Player" / "2 Players" buttons unchanged.

**Step 4: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: compact Continue button font and height for iPhone 2P mode"
```

---

### Task 6: Final verification

**Step 1: Run on iPhone SE simulator (smallest supported screen)**

Expected: in two-player mode, all elements visible — header, back button, both pickers with 84pt cards, continue button.

**Step 2: Run on iPhone 16 Pro Max simulator**

Expected: same as iPhone 16 Pro — compact layout, everything fits cleanly.

**Step 3: Run on iPad (any size)**

Expected: no visual change from before this feature branch — `.title3` labels, 100pt cards, `.title2` continue button.

**Step 4: Verify single-player mode on iPhone**

Expected: original layout — `isCompact2P` is false, all original values used.
