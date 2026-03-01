# Animated Environment Selection Cards

## Problem

The environment selection screen uses static pre-rendered snapshots. A previous attempt to animate them reused the full-size `buildBackground()` methods, which produced geometry sized for 390x844pt crammed into 160x80pt cards — resulting in tiny dots and overflowing shapes.

## Solution

Create dedicated card-sized preview scenes per environment, following the proven `LiveCharacterPreview` pattern. Each environment renderer gets a new `buildPreviewBackground()` method that draws miniature, hand-tuned geometry optimized for a 170x100pt card.

## Architecture

### New Files
- `LiveEnvironmentPreview.swift` — `EnvironmentPreviewScene` (SKScene) + `LiveEnvironmentPreview` (SwiftUI view)

### Modified Files
- `EnvironmentRenderer.swift` — Add `buildPreviewBackground(scene:size:parallax:)` to protocol
- 6 environment renderers — Implement `buildPreviewBackground` with card-scaled geometry
- `EnvironmentSelectionView.swift` — Replace static images with live previews, switch to 2-column grid

## Component Details

### EnvironmentPreviewScene (SKScene subclass)
- Size: 170x100pt
- Clear background for card material transparency
- `ParallaxBackground(baseSpeed: 20)` — ~7x slower than gameplay
- 15 FPS via `preferredFramesPerSecond`
- Includes ground tile as 1.0x parallax layer
- Sets `scene.backgroundColor` to environment's theme color

### LiveEnvironmentPreview (SwiftUI view)
- Takes `environment: GameEnvironment` and `isSelected: Bool`
- `SpriteView` with `.allowsTransparency`, 170x100pt frame

### EnvironmentSelectionView Changes
- 2-column `LazyVGrid` (up from 3-column)
- Card size: ~170x130pt (100pt preview + label/padding)
- Selected card: 1.05x scale + accent border

### Per-Environment Preview Content

| Environment | Far Layer | Mid Elements | Animated |
|---|---|---|---|
| Classic | Green hills (r:15-25pt) | Fluffy clouds (r:4-6pt) | Clouds drift |
| Jungle | Dark canopy circles | Mini hanging vines | Firefly glow dots |
| Arctic | White mountain peaks | Snow drift banks | Snowflakes falling |
| Desert | Sand dune curves | Mini cacti | Heat shimmer wave |
| Space | Nebula blobs | — | Twinkling stars |
| Underwater | Swaying seaweed | Light ray beams | Rising bubbles |

### Geometry Scaling
- Hills/mountains: 15-25pt radii (vs 55-80pt in game)
- Clouds: 4-6pt puff radii (vs 12-18pt in game)
- Ground strip: 8pt tall (vs ~30pt in game)
- All positions relative to 170x100 card size
- Same colors as gameplay

## Protocol Addition

```swift
protocol EnvironmentRenderer {
    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)
    func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)
    func buildObstacle(sceneHeight:gapCenterY:gapHeight:pipeWidth:) -> SKNode
    func buildGroundTile(size: CGSize) -> SKNode
    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene
}
```

## Performance
- 6 simultaneous SpriteKit scenes at 15 FPS
- Minimal geometry per scene (5-15 shape nodes)
- Slow parallax speed reduces update cost
