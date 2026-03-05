# Two-Player Position Rebalancing

## Problem

In two-player mode, obstacles move right-to-left. Player 1 (left, at 25% screen width) gets ~3x more reaction time than Player 2 (right, at 75%).

## Solution

Move both players toward center:

- Player 1: `0.25` → `0.35`
- Player 2: `0.75` → `0.65`

## Changes

- `GameScene.swift` `setupPlayers()`: Update the two X-position multipliers
- `GameScene.swift` `update()`: Update the X-position lock values to match

## Unchanged

- Touch zones (left half = P1, right half = P2)
- Divider line position (center)
- Single-player position (`0.3`, unchanged)
- All obstacle, scoring, and physics behavior

## Result

Reaction time ratio improves from ~3x to ~1.7x with a two-constant change.
