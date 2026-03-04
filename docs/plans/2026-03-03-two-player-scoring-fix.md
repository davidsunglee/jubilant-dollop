# Two-Player Scoring Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the bug where only one player's score increments when both players pass through a pipe in two-player mode.

**Architecture:** Replace the shared `Set<SKNode>` scored-pipe tracker with a `[Int: Set<SKNode>]` dictionary keyed by player index, so each player independently tracks which pipes they have already passed.

**Tech Stack:** Swift, SpriteKit

---

### Task 1: Fix per-player scored pipe tracking in GameScene

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift:22` (property declaration)
- Modify: `FlappyBird/Game/GameScene.swift:241-243` (scoring logic in `didBegin(_:)`)

No automated test infrastructure exists in this project. Manual verification is described below.

**Step 1: Change the `scoredPipes` property type**

In `FlappyBird/Game/GameScene.swift`, line 22, change:

```swift
var scoredPipes: Set<SKNode> = []
```

to:

```swift
var scoredPipes: [Int: Set<SKNode>] = [:]
```

**Step 2: Update the scoring guard and insert**

In `GameScene.swift`, within `didBegin(_:)`, lines 241–243, change:

```swift
let scoreNode = (categoryA == PhysicsCategory.scoreZone) ? bodyA.node : bodyB.node
guard let scoreNode = scoreNode, !scoredPipes.contains(scoreNode) else { return }
scoredPipes.insert(scoreNode)
```

to:

```swift
let scoreNode = (categoryA == PhysicsCategory.scoreZone) ? bodyA.node : bodyB.node
let alreadyScored = scoredPipes[playerNode.playerIndex]?.contains(scoreNode) ?? false
guard let scoreNode = scoreNode, !alreadyScored else { return }
scoredPipes[playerNode.playerIndex, default: []].insert(scoreNode)
```

> The two `scoredPipes.removeAll()` calls (in `setupScene` and on game-over) require no changes — they work identically on `[Int: Set<SKNode>]`.

**Step 3: Build the project**

Open the Xcode project and build (⌘B). Confirm zero errors and zero warnings related to these changes.

**Step 4: Manual verification**

Launch in two-player mode. Pass both characters through several pipes:
- Both player scores should increment on every pipe passed.
- Neither player should be able to score the same pipe twice (rapid contact shouldn't double-count).
- Single-player mode should be unaffected.

**Step 5: Commit**

```bash
git add FlappyBird/Game/GameScene.swift
git commit -m "fix: score each pipe independently per player in 2P mode"
```
