# Ready State: Smooth Game Start

## Problem

When the game starts, the character immediately plunges downward because gravity is active from the first frame. The player often isn't ready, making the start feel jarring.

## Solution

Add a "ready" state before active gameplay. The character hovers with a gentle bob animation, background scrolls, but no gravity or obstacles until the player's first tap.

## Design

### Ready State Behavior

- **Gravity:** Set to zero during ready state
- **Character:** Gentle bob animation (up/down ~10-15pt over ~0.8s, ease in/out)
- **Background:** Scrolls normally
- **Obstacles:** Not spawned until first tap
- **Music:** Plays during ready state (starts on scene load as it does now)

### First Tap Transition

When the player taps during the ready state:

1. Remove bob animation from all players
2. Set gravity to normal value (-5.0)
3. Start obstacle spawning
4. Set `isReady = false`, `isGameActive = true`
5. Apply jump impulse to the tapping player's character

### Implementation Approach

Add an `isReady` boolean to `GameScene`. Modify `setupScene()` to enter the ready state instead of immediately activating gameplay:

- `setupWorld()` sets gravity to zero
- `setupPlayers()` adds bob animation to each player
- `startSpawning()` is deferred
- `isReady = true`, `isGameActive = false`

New method `activateGameplay()`:

- Sets gravity to normal
- Removes bob actions from players
- Calls `startSpawning()`
- Sets `isReady = false`, `isGameActive = true`

### Input Handling Changes

In `GameScene+Input.swift`, `touchesBegan` and `keyDown` check `isReady` before `isGameActive`:

- If `isReady`: call `activateGameplay()`, then `handleJump(forPlayer:)` for the tapping player
- If `isGameActive`: existing jump behavior
- Otherwise: ignore

### 2-Player Mode

- Both characters bob independently during ready state
- Either player's first tap activates gameplay for both players
- The tapping player gets the jump impulse; the other player starts falling under gravity
- This feels natural: in 2P mode both players are watching, so one player's tap signals "go" for both

### Background Scrolling During Ready State

The `update()` loop currently guards on `isGameActive`. The parallax background update needs to run during the ready state too, so the guard changes to `guard isGameActive || isReady`.

### Files to Modify

| File | Change |
|------|--------|
| `GameScene.swift` | Add `isReady` property, modify `setupScene()` to enter ready state, add `activateGameplay()` method, update `update()` guard |
| `GameScene+Input.swift` | Add `isReady` check before `isGameActive` guard in `touchesBegan`, `keyDown`, and `handleJump` |
| `PlayerNode.swift` | Add `startBobAnimation()` and `stopBobAnimation()` methods |
