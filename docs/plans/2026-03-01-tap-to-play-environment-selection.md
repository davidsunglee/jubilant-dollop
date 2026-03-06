# Tap-to-Play Environment Selection Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make tapping an environment card start the game immediately, eliminating the two-step select-then-start flow and removing the ScrollView.

**Architecture:** Modify `EnvironmentSelectionView` to remove ScrollView, Start button, and persistent selection state. Add a brief highlight animation (~0.3s) on tap before transitioning to gameplay.

**Tech Stack:** SwiftUI, SpriteKit (existing)

---

### Task 1: Simplify EnvironmentSelectionView

**Files:**
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift`

**Step 1: Remove `selectedEnvironment` state and add tap-triggered state**

Remove the line:
```swift
@State private var selectedEnvironment: GameEnvironment? = nil
```

Add in its place:
```swift
@State private var tappedEnvironment: GameEnvironment? = nil
```

**Step 2: Replace ScrollView with VStack and remove Start button**

Replace the entire body contents between `ZStack {` and the back button overlay (lines 13–50) with:

```swift
            VStack(spacing: 20) {
                Text("Select Environment")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .offset(y: headerVisible ? 0 : -15)
                    .opacity(headerVisible ? 1 : 0)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(GameEnvironment.allCases) { environment in
                        environmentCard(environment: environment, isSelected: tappedEnvironment == environment)
                            .onTapGesture {
                                guard tappedEnvironment == nil else { return }
                                tappedEnvironment = environment
                                router.selectEnvironment(environment)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    router.startGame()
                                }
                            }
                    }
                }
                .frame(maxWidth: 750)
                .padding(.horizontal)
                .opacity(cardsVisible ? 1 : 0)
            }
            .padding(.vertical)
```

Key changes:
- `ScrollView` removed — plain `VStack` now
- Start button removed entirely
- `guard tappedEnvironment == nil` prevents double-taps
- 0.3s delay shows the selection highlight before transitioning

**Step 3: Update onAppear to reset `tappedEnvironment` instead of `selectedEnvironment`**

In the `.onAppear` block, change:
```swift
selectedEnvironment = nil
```
to:
```swift
tappedEnvironment = nil
```

**Step 4: Build and test**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'`
Expected: Build succeeds with no errors

**Step 5: Manual test**

Launch in simulator. On the environment selection screen:
- Tap any environment card
- Verify: card highlights briefly (~0.3s), then game starts
- Verify: no scrolling behavior
- Verify: back button still works

**Step 6: Commit**

```bash
git add FlappyBird/Views/EnvironmentSelectionView.swift
git commit -m "feat: tap environment card to start game immediately

Remove the two-step select-then-start flow. Tapping an environment
card now shows a brief highlight and launches the game directly.
Remove ScrollView since content fits on screen without it."
```
