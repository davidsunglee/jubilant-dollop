# Environment Redesign

## Problem

All 6 environments are visually identical aside from color — solid-color backgrounds, plain rectangular pipes, and a flat ground strip. Nothing distinguishes Jungle from Arctic from Space beyond palette swaps.

## Solution

Per-environment renderer classes that build unique backgrounds (multi-layer parallax with scenery), custom obstacle shapes, themed ground strips, and signature animated elements. Environment selection screen shows rendered mini-scene previews.

## Architecture

An `EnvironmentRenderer` protocol with three methods:

```
protocol EnvironmentRenderer {
    func buildBackground(in scene: SKScene, size: CGSize) -> [SKNode]
    func buildObstacle(sceneHeight:, gapCenterY:, gapHeight:, pipeWidth:) -> SKNode
    func buildGround(size: CGSize) -> SKNode
    func renderPreview(size: CGSize) -> PlatformImage?
}
```

Six conforming classes: `ClassicEnvironmentRenderer`, `JungleEnvironmentRenderer`, `UnderwaterEnvironmentRenderer`, `ArcticEnvironmentRenderer`, `DesertEnvironmentRenderer`, `SpaceEnvironmentRenderer`.

`GameEnvironment` gains a `renderer` property returning the correct class.

`ParallaxBackground` upgraded to multi-layer with per-layer speed multipliers.

`PipeNode` replaced by `ObstacleNode` delegating visual construction to the renderer.

`GameScene.setupBackground()` and `spawnPipePair()` call the renderer.

## ParallaxBackground Upgrade

Support multiple layers at different scroll speeds:

```
struct ParallaxLayer {
    nodes: [SKNode]
    speedMultiplier: CGFloat  // 0.3 = far/slow, 1.0 = near/fast
}
```

Typical layer stack:
- Far layer (0.3x): distant scenery (mountains, dunes, nebula)
- Mid layer (0.6x): mid-ground decoration (trees, vines, cacti)
- Ground layer (1.0x): themed ground strip, synced with obstacles

## Background Designs

**Classic** -- Light blue gradient sky. White fluffy clouds (overlapping ellipses) at two parallax speeds. Distant green rolling hills. Drifting bird dots.

**Jungle** -- Deep green gradient darkening downward. Dense canopy (overlapping dark green circles) at far parallax. Hanging vines (thin green rectangles) at mid parallax. Pulsing fireflies.

**Underwater** -- Dark navy gradient lightening upward. Distant seaweed strands swaying. Light rays (semi-transparent white triangles) angling from top. Bubbles floating upward with wobble.

**Arctic** -- Pale ice-blue gradient. Distant snowy mountain silhouettes (triangles) at far parallax. Snow drifts (white rounded humps). Falling snowflakes with horizontal drift.

**Desert** -- Warm sand-to-orange gradient. Distant sand dunes (smooth curves) at far parallax. Cactus silhouettes at mid parallax. Heat shimmer (subtle vertical oscillation on far layer).

**Space** -- Black with static star field (random dots of varying brightness). Distant nebula smudges (large semi-transparent colored ellipses). Occasional shooting star streaks.

## Obstacle Designs

Physics bodies remain rectangular (same gameplay). Visual construction is unique per environment.

**Classic** -- Green pipes with subtle gradient (darker edges, highlight stripe). Slightly rounded caps.

**Jungle** -- Brown bamboo stalks. Segmented with horizontal joint lines every ~30pts. Small leaves at joints. Thicker bamboo-node caps.

**Underwater** -- Pink/red coral formations. Bumpy edges (overlapping circles). Small barnacles and starfish attached.

**Arctic** -- Pale blue ice pillars. White frost shapes along edges. Icicles (triangles) hanging from top obstacle bottom / growing from bottom obstacle top. Snow-drift caps.

**Desert** -- Sandstone rock columns. Layered tan/orange rectangles of varying widths. Crack lines on surface. Flat mesa-top caps.

**Space** -- Neon purple energy barriers. Brighter inner glow rectangle. Electrical spark dots along edges. Pulsing glow caps.

## Ground Designs

40px themed ground strip per environment.

**Classic** -- Sandy brown base with green grass line on top. Small grass tufts (triangles) at random intervals.

**Jungle** -- Dark earthy brown with tangled root lines. Small mushrooms scattered.

**Underwater** -- Sandy ocean floor (tan/beige). Small rocks, shells, seaweed tufts.

**Arctic** -- White snow with blue-grey ice layer. Snow drift bumps along top edge.

**Desert** -- Light sand with darker ripple lines. Small rocks and bleached bone shapes.

**Space** -- Dark purple metallic platform with neon edge line. Small rivets (dots) on surface.

## Animated Elements

| Environment | Element | Animation |
|-------------|---------|-----------|
| Classic | Drifting birds (2-3 dots) | Slow horizontal across top |
| Jungle | Fireflies (3-4 yellow dots) | Pulse opacity, gentle drift |
| Underwater | Bubbles (4-5 circles) | Float up with wobble, respawn at bottom |
| Arctic | Snowflakes (6-8 white dots) | Fall with horizontal drift, respawn at top |
| Desert | Heat shimmer | Vertical oscillation on far parallax layer |
| Space | Shooting stars (1 at a time) | Bright line streak, respawn after random delay |

## Environment Selection Screen

Replace solid-color cards with rendered mini-scene previews using off-screen SKView rendering. Each preview shows background gradient, ground strip, sample obstacle pair, and signature decorative elements. Cache rendered images.

## Files Changed

- New: `FlappyBird/Game/EnvironmentRenderer.swift` (protocol)
- New: `FlappyBird/Game/Environments/ClassicEnvironmentRenderer.swift`
- New: `FlappyBird/Game/Environments/JungleEnvironmentRenderer.swift`
- New: `FlappyBird/Game/Environments/UnderwaterEnvironmentRenderer.swift`
- New: `FlappyBird/Game/Environments/ArcticEnvironmentRenderer.swift`
- New: `FlappyBird/Game/Environments/DesertEnvironmentRenderer.swift`
- New: `FlappyBird/Game/Environments/SpaceEnvironmentRenderer.swift`
- Modify: `FlappyBird/Game/ParallaxBackground.swift` (multi-layer support)
- Modify/Replace: `FlappyBird/Game/PipeNode.swift` -> `ObstacleNode.swift`
- Modify: `FlappyBird/Models/GameEnvironment.swift` (add renderer property)
- Modify: `FlappyBird/Game/GameScene.swift` (use renderer for setup)
- Modify: `FlappyBird/Game/GameScene+Spawning.swift` (use renderer for obstacles)
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift` (rendered previews)
