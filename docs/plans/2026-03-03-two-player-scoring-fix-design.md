# Two-Player Scoring Fix Design

**Date:** 2026-03-03

## Problem

In two-player mode, only one player's score increments when characters pass through pipes. The second player never receives credit for passing the same pipe.

## Root Cause

`GameScene.scoredPipes` is a `Set<SKNode>` shared across all players. It was intended to prevent a single player from scoring multiple times on the same pipe (physics contacts can fire multiple times). However, when Player 1 passes a pipe, the score zone node is inserted into `scoredPipes`. When Player 2 subsequently hits the same score zone, the guard check `!scoredPipes.contains(scoreNode)` returns early — Player 2 never scores.

## Design

**File:** `FlappyBird/Game/GameScene.swift`

Change `scoredPipes` from a flat set to a dictionary keyed by player index:

```swift
// Before
var scoredPipes: Set<SKNode> = []

// After
var scoredPipes: [Int: Set<SKNode>] = [:]
```

Update the scoring guard and insert in `didBegin(_:)`:

```swift
// Before
guard let scoreNode = scoreNode, !scoredPipes.contains(scoreNode) else { return }
scoredPipes.insert(scoreNode)

// After
let alreadyScored = scoredPipes[playerNode.playerIndex]?.contains(scoreNode) ?? false
guard let scoreNode = scoreNode, !alreadyScored else { return }
scoredPipes[playerNode.playerIndex, default: []].insert(scoreNode)
```

`removeAll()` calls on `scoredPipes` require no changes.

## Result

Each player independently tracks which pipes they have already passed. Both players score on every pipe; neither player can double-score.
