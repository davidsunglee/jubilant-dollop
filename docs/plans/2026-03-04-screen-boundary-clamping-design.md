# Screen Boundary Clamping Design

**Date:** 2026-03-04
**Status:** Approved

## Problem

Two bugs occur when the character reaches the top or bottom of the screen:

1. **Top escape:** The character flies above the visible screen and disappears. The physics boundary is placed at `y = height + 20` (20 points above the visible area), and during invincibility frames `collisionBitMask` is set to `none`, allowing the character to pass through.

2. **Bottom limbo:** The character falls below the screen and gets stuck. Same invincibility bypass — the character passes through the bottom boundary (at `y = -20`) and gravity keeps pulling them further down. Flapping can't overcome the distance to get back on screen.

## Approach

**Position clamping in the update loop** — the simplest and most reliable approach. The `GameScene.update()` method already runs every frame and locks the player's X position. We extend this to also enforce Y boundaries.

### Top — Hard Ceiling

- Clamp `player.position.y` to `size.height - margin` where margin is half the character's physics body height, keeping the visual fully on screen
- When clamped, zero out upward velocity (`physicsBody?.velocity.dy = 0`) to prevent velocity accumulation against the ceiling

### Bottom — Always Fatal

- If `player.position.y` falls below the ground height (40pt ground tiles), kill the player immediately
- This bypasses invincibility — falling to the ground is always lethal, matching classic Flappy Bird behavior
- Uses the existing `die()` flow and triggers the "all players dead" game-over check

### Existing Physics Boundaries

Keep the existing physics boundary nodes as a secondary safety net. The update loop clamping is the primary mechanism.

## Implementation Location

All changes go in `GameScene.update()` in `GameScene.swift`, inside the existing `for player in players` loop, right after the X-position lock and rotation clamping.

## Alternatives Considered

1. **Fix physics boundaries** — Move to visible edges, add separate physics category for ground to bypass invincibility. More complex and still relies on physics timing.
2. **Hybrid** — Physics for ceiling, update loop for bottom. Two mechanisms for two edges adds complexity.

Both rejected in favor of the simpler update-loop approach.
