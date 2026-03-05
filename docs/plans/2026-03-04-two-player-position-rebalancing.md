# Two-Player Position Rebalancing Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Improve two-player fairness by moving both players closer to center, reducing reaction time disparity from ~3x to ~1.7x.

**Architecture:** Change 4 position multiplier constants in `GameScene.swift` — two in `setupPlayers()` (initial placement) and two in `update()` (X-position lock).

**Tech Stack:** Swift / SpriteKit

---

### Task 1: Update player positions in setupPlayers()

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift:95,106`

**Step 1: Change P1 two-player X position**

In `setupPlayers()`, change line 95:

```swift
// Before:
p1X = size.width * 0.25
// After:
p1X = size.width * 0.35
```

**Step 2: Change P2 X position**

In `setupPlayers()`, change line 106:

```swift
// Before:
p2.position = CGPoint(x: size.width * 0.75, y: size.height * 0.5)
// After:
p2.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
```

---

### Task 2: Update X-position lock in update()

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift:202`

**Step 1: Change the X-position lock values**

In `update()`, change line 202:

```swift
// Before:
targetX = player.playerIndex == 1 ? size.width * 0.25 : size.width * 0.75
// After:
targetX = player.playerIndex == 1 ? size.width * 0.35 : size.width * 0.65
```

---

### Task 3: Build and verify

**Step 1: Build the project**

Run: `xcodebuild -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 2: Commit**

```bash
git add FlappyBird/Game/GameScene.swift
git commit -m "fix: rebalance two-player X positions for fairer reaction times"
```
