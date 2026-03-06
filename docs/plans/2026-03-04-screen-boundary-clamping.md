# Screen Boundary Clamping Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Prevent characters from flying off screen — hard ceiling at top, always-fatal ground at bottom.

**Architecture:** Add Y-axis boundary enforcement in `GameScene.update()`, alongside the existing X-position lock. Top boundary clamps position and zeros velocity. Bottom boundary kills the player immediately, bypassing invincibility.

**Tech Stack:** SpriteKit, Swift

---

### Task 1: Add ground-kill logic in the update loop

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift:197-213` (the `for player in players` loop in `update()`)

**Step 1: Add bottom boundary kill after rotation clamping**

Inside the `for player in players` loop in `update()`, after the rotation clamping block (line ~212), add:

```swift
// Kill player if they fall to ground level (bypasses invincibility)
let groundHeight: CGFloat = 40
if player.position.y < groundHeight {
    player.die()
    AudioManager.shared.playCollisionSound()
    router.forceKillPlayer(player.playerIndex)

    // Check if all players dead
    if players.allSatisfy({ !$0.isAlive }) {
        isGameActive = false
        removeAllActions()
        scoredPipes.removeAll()
        AudioManager.shared.stopMusic()
    }
}
```

**Step 2: Add `forceKillPlayer` to GameRouter**

This method sets lives to 0 and triggers death without the "survived" check. Open `FlappyBird/ViewModels/GameRouter.swift` and add after the `playerHit` method:

```swift
func forceKillPlayer(_ player: Int) {
    guard player >= 1 && player <= 2 else { return }
    let index = player - 1
    lives[index] = 0
    playerDied(player)
}
```

**Step 3: Build and verify**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: Build succeeds

**Step 4: Manual test**

Launch in simulator. Let the character fall without tapping. Confirm it dies when reaching the ground, not when falling off screen into limbo.

**Step 5: Commit**

```bash
git add FlappyBird/Game/GameScene.swift FlappyBird/ViewModels/GameRouter.swift
git commit -m "feat: kill player on ground contact, bypassing invincibility"
```

---

### Task 2: Add hard ceiling clamp in the update loop

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift:197-213` (same `for player in players` loop)

**Step 1: Add top boundary clamp after rotation clamping, before the ground-kill block**

```swift
// Hard ceiling: clamp to top of screen
let topMargin = player.character.physicsBodySize.height / 2
let maxY = size.height - topMargin
if player.position.y > maxY {
    player.position.y = maxY
    if let vy = player.physicsBody?.velocity.dy, vy > 0 {
        player.physicsBody?.velocity.dy = 0
    }
}
```

**Step 2: Build and verify**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: Build succeeds

**Step 3: Manual test**

Launch in simulator. Tap rapidly to fly up. Confirm the character stops at the top of the screen and stays visible. It should not bounce — just stop and then fall with gravity.

**Step 4: Commit**

```bash
git add FlappyBird/Game/GameScene.swift
git commit -m "feat: add hard ceiling clamp to prevent flying off top of screen"
```

---

### Task 3: Verify invincibility edge cases

**Files:**
- No code changes expected — manual testing only

**Step 1: Test invincibility + top boundary**

Launch the game, get hit by a pipe (triggering invincibility), then rapidly tap to fly up during the flashing animation. Confirm the character cannot escape the top of the screen while invincible.

**Step 2: Test invincibility + bottom boundary**

Get hit by a pipe, then stop tapping. Let the character fall during invincibility. Confirm the character dies when reaching the ground — not stuck in limbo below the screen.

**Step 3: Test 2-player mode**

Play in 2-player mode. Confirm both players respect the ceiling and ground boundaries independently.

**Step 4: If all tests pass, commit is not needed (no code changes)**

If any edge case fails, fix and commit before proceeding.
