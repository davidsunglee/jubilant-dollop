# Tap-to-Play Environment Selection

## Problem

The environment selection screen requires two steps (select, then tap Start) and uses a ScrollView that's unnecessary. Simplify to a single tap that launches the game immediately.

## Design

### Changes to `EnvironmentSelectionView`

1. **Remove ScrollView** — replace with a plain VStack
2. **Remove the "Start" button**
3. **Remove `selectedEnvironment` state** — no persistent selection needed
4. **On card tap**: show brief selection highlight (~0.3s), then call `router.selectEnvironment(env)` + `router.startGame()`

### Layout

Header ("Select Environment") + 3x2 grid of environment cards + back button — all in a non-scrollable VStack. Cards keep their live previews and visual styling.

### No changes needed to

- `GameRouter` — `selectEnvironment()` and `startGame()` already exist
- `GameScene` — reads config as before
- Environment renderers — unchanged
