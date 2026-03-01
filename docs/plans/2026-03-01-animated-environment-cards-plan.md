# Animated Environment Cards Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace static environment selection cards with live animated SpriteKit previews showing miniature parallax environments.

**Architecture:** Each environment renderer gets a new `buildPreviewBackground()` method that builds card-sized (170x100pt) parallax scenes with hand-tuned miniature geometry. A new `LiveEnvironmentPreview` SwiftUI view wraps an `EnvironmentPreviewScene` (SKScene subclass) in a `SpriteView`, following the same pattern as the existing `LiveCharacterPreview`. The selection view switches from 3-column static images to a 2-column grid of live previews.

**Tech Stack:** SwiftUI, SpriteKit, `SpriteView`, `ParallaxBackground`

**Design doc:** `docs/plans/2026-03-01-animated-environment-cards-design.md`

---

### Task 1: Add `buildPreviewBackground` to EnvironmentRenderer Protocol

**Files:**
- Modify: `FlappyBird/Game/EnvironmentRenderer.swift:8-23`

**Step 1: Add the new method to the protocol**

Add `buildPreviewBackground` between `buildBackground` and `buildObstacle` in the protocol:

```swift
protocol EnvironmentRenderer {
    /// Build background layers (gradient sky, scenery, animated elements).
    /// Returns nodes that should be added to the scene.
    /// Also sets up ParallaxBackground layers.
    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)

    /// Build miniature background layers for card preview (170x100pt).
    /// Uses the same ParallaxBackground system but with card-scaled geometry.
    func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)

    /// Build a pair of obstacles (top + bottom) with gap.
    /// Returns an SKNode with physics bodies configured.
    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode

    /// Build the ground strip node for one parallax tile.
    func buildGroundTile(size: CGSize) -> SKNode

    /// Render a preview image for the environment selection screen.
    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene
}
```

**Step 2: Build the project to verify it compiles**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: Build FAILS — the 6 renderer classes don't conform to the updated protocol yet. This is expected; we'll fix them in subsequent tasks.

**Step 3: Commit**

```bash
git add FlappyBird/Game/EnvironmentRenderer.swift
git commit -m "feat: add buildPreviewBackground to EnvironmentRenderer protocol"
```

---

### Task 2: Create LiveEnvironmentPreview View

**Files:**
- Create: `FlappyBird/Views/LiveEnvironmentPreview.swift`
- Reference: `FlappyBird/Views/LiveCharacterPreview.swift` (pattern to follow)
- Reference: `FlappyBird/Game/ParallaxBackground.swift` (used in scene)

**Step 1: Create `LiveEnvironmentPreview.swift`**

This file contains two types:
1. `EnvironmentPreviewScene` — an SKScene that creates a ParallaxBackground and calls `buildPreviewBackground()` on the environment's renderer, then updates parallax each frame.
2. `LiveEnvironmentPreview` — a SwiftUI view wrapping the scene in a `SpriteView`.

```swift
import SwiftUI
import SpriteKit

class EnvironmentPreviewScene: SKScene {
    private let environment: GameEnvironment
    private var parallax: ParallaxBackground?
    private var lastUpdateTime: TimeInterval = 0

    init(environment: GameEnvironment, size: CGSize) {
        self.environment = environment
        super.init(size: size)
        backgroundColor = environment.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        view.preferredFramesPerSecond = 15

        let parallax = ParallaxBackground(baseSpeed: 20)
        let renderer = environment.renderer
        renderer.buildPreviewBackground(scene: self, size: size, parallax: parallax)

        // Add ground as 1.0x parallax layer
        let groundHeight: CGFloat = 8
        let groundSize = CGSize(width: size.width, height: groundHeight)
        var groundNodes: [SKNode] = []
        for i in 0..<2 {
            let tile = renderer.buildGroundTile(size: groundSize)
            tile.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
            tile.zPosition = -2
            addChild(tile)
            groundNodes.append(tile)
        }
        parallax.addLayer(nodes: groundNodes, speedMultiplier: 1.0, width: size.width)

        self.parallax = parallax
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 15.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        parallax?.update(deltaTime: min(deltaTime, 0.1))
    }
}

struct LiveEnvironmentPreview: View {
    let environment: GameEnvironment

    private var scene: EnvironmentPreviewScene {
        let scene = EnvironmentPreviewScene(
            environment: environment,
            size: CGSize(width: 170, height: 100)
        )
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: 170, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Views/LiveEnvironmentPreview.swift
git commit -m "feat: add LiveEnvironmentPreview with EnvironmentPreviewScene"
```

---

### Task 3: Implement Classic buildPreviewBackground

**Files:**
- Modify: `FlappyBird/Game/Environments/ClassicEnvironmentRenderer.swift`

**Step 1: Add `buildPreviewBackground` method**

Add this method after `buildBackground` (after line 83). This creates card-sized hills, clouds, and drifting birds using the same parallax system:

```swift
func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
    scene.backgroundColor = .cyan

    // Far layer: mini green hills (0.3x)
    var farNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        let hillPositions: [(x: CGFloat, radius: CGFloat)] = [
            (size.width * 0.2, 18),
            (size.width * 0.5, 24),
            (size.width * 0.8, 16),
        ]
        for hp in hillPositions {
            let hill = SKShapeNode(circleOfRadius: hp.radius)
            hill.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
            hill.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 0.2, alpha: 1)
            hill.lineWidth = 0.5
            hill.position = CGPoint(x: hp.x, y: 8 + hp.radius * 0.3)
            container.addChild(hill)
        }

        container.zPosition = -8
        scene.addChild(container)
        farNodes.append(container)
    }
    parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

    // Mid layer: mini fluffy clouds (0.5x)
    var midNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        let cloudPositions: [(x: CGFloat, y: CGFloat, scale: CGFloat)] = [
            (size.width * 0.2, size.height * 0.75, 0.35),
            (size.width * 0.6, size.height * 0.85, 0.25),
            (size.width * 0.85, size.height * 0.65, 0.3),
        ]
        for cp in cloudPositions {
            let cloud = buildCloud(scale: cp.scale)
            cloud.position = CGPoint(x: cp.x, y: cp.y)
            container.addChild(cloud)
        }

        container.zPosition = -6
        scene.addChild(container)
        midNodes.append(container)
    }
    parallax.addLayer(nodes: midNodes, speedMultiplier: 0.5, width: size.width)
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/ClassicEnvironmentRenderer.swift
git commit -m "feat: add Classic buildPreviewBackground with mini hills and clouds"
```

---

### Task 4: Implement Jungle buildPreviewBackground

**Files:**
- Modify: `FlappyBird/Game/Environments/JungleEnvironmentRenderer.swift`

**Step 1: Add `buildPreviewBackground` method**

Add after `buildBackground` (after line 89):

```swift
func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
    scene.backgroundColor = .systemGreen

    // Far layer: mini canopy circles (0.3x)
    var farNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        for j in 0..<4 {
            let canopy = SKShapeNode(circleOfRadius: CGFloat.random(in: 14...22))
            canopy.fillColor = SKColor(red: 0.05, green: CGFloat.random(in: 0.3...0.45), blue: 0.05, alpha: 0.8)
            canopy.strokeColor = .clear
            canopy.position = CGPoint(
                x: CGFloat(j) * size.width / 3,
                y: size.height - CGFloat.random(in: 4...14)
            )
            container.addChild(canopy)
        }

        container.zPosition = -8
        scene.addChild(container)
        farNodes.append(container)
    }
    parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

    // Mid layer: mini hanging vines (0.6x)
    var midNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        for j in 0..<3 {
            let vineHeight = CGFloat.random(in: 15...35)
            let vine = SKShapeNode(rectOf: CGSize(width: 1.5, height: vineHeight), cornerRadius: 0.5)
            vine.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.1, alpha: 0.7)
            vine.strokeColor = .clear
            vine.position = CGPoint(
                x: CGFloat(j) * size.width / 2 + CGFloat.random(in: 0...15),
                y: size.height - vineHeight / 2
            )
            container.addChild(vine)

            let leaf = SKShapeNode(ellipseOf: CGSize(width: 4, height: 2.5))
            leaf.fillColor = SKColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 0.8)
            leaf.strokeColor = .clear
            leaf.position = CGPoint(x: vine.position.x, y: size.height - vineHeight - 1)
            container.addChild(leaf)
        }

        container.zPosition = -6
        scene.addChild(container)
        midNodes.append(container)
    }
    parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)

    // Animated: mini fireflies
    for _ in 0..<3 {
        let firefly = SKShapeNode(circleOfRadius: 1.5)
        firefly.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1)
        firefly.strokeColor = .clear
        firefly.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: size.height * 0.3...size.height * 0.7)
        )
        firefly.zPosition = -4
        firefly.alpha = 0.3
        scene.addChild(firefly)

        let glow = SKAction.fadeAlpha(to: 1.0, duration: TimeInterval.random(in: 0.8...1.5))
        let dim = SKAction.fadeAlpha(to: 0.2, duration: TimeInterval.random(in: 0.8...1.5))
        let drift = SKAction.moveBy(
            x: CGFloat.random(in: -10...10),
            y: CGFloat.random(in: -8...8),
            duration: 3.0
        )
        let driftBack = drift.reversed()
        firefly.run(SKAction.repeatForever(SKAction.sequence([glow, dim])))
        firefly.run(SKAction.repeatForever(SKAction.sequence([drift, driftBack])))
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/JungleEnvironmentRenderer.swift
git commit -m "feat: add Jungle buildPreviewBackground with canopy, vines, fireflies"
```

---

### Task 5: Implement Arctic buildPreviewBackground

**Files:**
- Modify: `FlappyBird/Game/Environments/ArcticEnvironmentRenderer.swift`

**Step 1: Add `buildPreviewBackground` method**

Add after `buildBackground` (after line 93):

```swift
func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
    scene.backgroundColor = SKColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1)

    // Far layer: mini mountain peaks (0.3x)
    var farNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        let mountains: [(x: CGFloat, baseWidth: CGFloat, peakHeight: CGFloat)] = [
            (size.width * 0.15, 40, 40),
            (size.width * 0.45, 55, 52),
            (size.width * 0.75, 35, 35),
            (size.width * 0.95, 45, 42),
        ]
        for m in mountains {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: m.x - m.baseWidth / 2, y: 8))
            path.addLine(to: CGPoint(x: m.x, y: 8 + m.peakHeight))
            path.addLine(to: CGPoint(x: m.x + m.baseWidth / 2, y: 8))
            path.closeSubpath()

            let mountain = SKShapeNode(path: path)
            mountain.fillColor = SKColor(white: 0.95, alpha: 1)
            mountain.strokeColor = SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 1)
            mountain.lineWidth = 0.5
            container.addChild(mountain)
        }

        container.zPosition = -8
        scene.addChild(container)
        farNodes.append(container)
    }
    parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

    // Mid layer: mini snow drifts (0.6x)
    var midNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        let driftPositions: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
            (size.width * 0.25, 30, 8),
            (size.width * 0.55, 35, 10),
            (size.width * 0.8, 25, 7),
        ]
        for d in driftPositions {
            let drift = SKShapeNode(ellipseOf: CGSize(width: d.w, height: d.h))
            drift.fillColor = SKColor(white: 1.0, alpha: 0.8)
            drift.strokeColor = .clear
            drift.position = CGPoint(x: d.x, y: 12 + d.h / 2)
            container.addChild(drift)
        }

        container.zPosition = -6
        scene.addChild(container)
        midNodes.append(container)
    }
    parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)

    // Animated: mini snowflakes
    for _ in 0..<5 {
        let snowflake = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
        snowflake.fillColor = .white
        snowflake.strokeColor = .clear
        snowflake.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: size.height * 0.5...size.height)
        )
        snowflake.zPosition = -4
        snowflake.alpha = CGFloat.random(in: 0.5...1.0)
        scene.addChild(snowflake)

        let fall = SKAction.moveBy(
            x: CGFloat.random(in: -10...10),
            y: -(size.height + 10),
            duration: TimeInterval.random(in: 6...12)
        )
        let reset = SKAction.run {
            snowflake.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 5
            )
        }
        snowflake.run(SKAction.repeatForever(SKAction.sequence([fall, reset])))
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/ArcticEnvironmentRenderer.swift
git commit -m "feat: add Arctic buildPreviewBackground with mountains, drifts, snowflakes"
```

---

### Task 6: Implement Desert buildPreviewBackground

**Files:**
- Modify: `FlappyBird/Game/Environments/DesertEnvironmentRenderer.swift`

**Step 1: Add `buildPreviewBackground` method**

Add after `buildBackground` (after line 64):

```swift
func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
    scene.backgroundColor = .systemYellow

    // Far layer: mini sand dunes with heat shimmer (0.3x)
    var farNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        let dunes: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
            (size.width * 0.2, 45, 14),
            (size.width * 0.5, 55, 18),
            (size.width * 0.8, 40, 12),
        ]
        for d in dunes {
            let dune = SKShapeNode(ellipseOf: CGSize(width: d.w, height: d.h))
            dune.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.5, alpha: 1)
            dune.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.45, alpha: 1)
            dune.lineWidth = 0.5
            dune.position = CGPoint(x: d.x, y: 8 + d.h * 0.3)
            container.addChild(dune)
        }

        container.zPosition = -8
        scene.addChild(container)
        farNodes.append(container)

        // Heat shimmer
        let shimmerUp = SKAction.moveBy(x: 0, y: 1.5, duration: 2.0)
        let shimmerDown = SKAction.moveBy(x: 0, y: -1.5, duration: 2.0)
        shimmerUp.timingMode = .easeInEaseOut
        shimmerDown.timingMode = .easeInEaseOut
        container.run(SKAction.repeatForever(SKAction.sequence([shimmerUp, shimmerDown])))
    }
    parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

    // Mid layer: mini cacti (0.6x)
    var midNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        for j in 0..<2 {
            let cactus = buildMiniCactus()
            cactus.position = CGPoint(
                x: CGFloat(j) * size.width / 1.5 + CGFloat.random(in: 10...30),
                y: 14
            )
            container.addChild(cactus)
        }

        container.zPosition = -6
        scene.addChild(container)
        midNodes.append(container)
    }
    parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)
}

private func buildMiniCactus() -> SKNode {
    let cactus = SKNode()
    let cactusColor = SKColor(red: 0.15, green: 0.45, blue: 0.1, alpha: 0.8)

    let trunk = SKShapeNode(rectOf: CGSize(width: 4, height: 14), cornerRadius: 1)
    trunk.fillColor = cactusColor
    trunk.strokeColor = .clear
    trunk.position = CGPoint(x: 0, y: 7)
    cactus.addChild(trunk)

    let leftArm = SKShapeNode(rectOf: CGSize(width: 3, height: 7), cornerRadius: 1)
    leftArm.fillColor = cactusColor
    leftArm.strokeColor = .clear
    leftArm.position = CGPoint(x: -5, y: 10)
    cactus.addChild(leftArm)

    let rightArm = SKShapeNode(rectOf: CGSize(width: 3, height: 5), cornerRadius: 1)
    rightArm.fillColor = cactusColor
    rightArm.strokeColor = .clear
    rightArm.position = CGPoint(x: 5, y: 9)
    cactus.addChild(rightArm)

    return cactus
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/DesertEnvironmentRenderer.swift
git commit -m "feat: add Desert buildPreviewBackground with dunes, cacti, shimmer"
```

---

### Task 7: Implement Space buildPreviewBackground

**Files:**
- Modify: `FlappyBird/Game/Environments/SpaceEnvironmentRenderer.swift`

**Step 1: Add `buildPreviewBackground` method**

Add after `buildBackground` (after line 81):

```swift
func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
    scene.backgroundColor = .black

    // Static twinkling stars (no parallax - fixed in scene)
    for _ in 0..<15 {
        let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.2))
        star.fillColor = Bool.random()
            ? SKColor(white: 1.0, alpha: CGFloat.random(in: 0.6...1.0))
            : SKColor(red: 0.7, green: 0.8, blue: 1.0, alpha: CGFloat.random(in: 0.5...0.9))
        star.strokeColor = .clear
        star.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height)
        )
        star.zPosition = -9
        scene.addChild(star)

        let twinkle = SKAction.sequence([
            SKAction.fadeAlpha(to: CGFloat.random(in: 0.3...0.6), duration: TimeInterval.random(in: 1.5...3.0)),
            SKAction.fadeAlpha(to: 1.0, duration: TimeInterval.random(in: 1.5...3.0)),
        ])
        star.run(SKAction.repeatForever(twinkle))
    }

    // Far layer: mini nebula smudges (0.3x)
    var farNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        let nebulaConfigs: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: SKColor)] = [
            (size.width * 0.3, size.height * 0.65, 35, 20,
             SKColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.2)),
            (size.width * 0.7, size.height * 0.4, 28, 18,
             SKColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 0.18)),
        ]
        for nc in nebulaConfigs {
            let nebula = SKShapeNode(ellipseOf: CGSize(width: nc.w, height: nc.h))
            nebula.fillColor = nc.color
            nebula.strokeColor = .clear
            nebula.position = CGPoint(x: nc.x, y: nc.y)
            container.addChild(nebula)
        }

        container.zPosition = -8
        scene.addChild(container)
        farNodes.append(container)
    }
    parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

    // Animated: mini shooting star
    let shootingStar = SKShapeNode(ellipseOf: CGSize(width: 4, height: 1))
    shootingStar.fillColor = .white
    shootingStar.strokeColor = .clear
    shootingStar.position = CGPoint(x: -10, y: size.height * 0.8)
    shootingStar.zPosition = -5
    shootingStar.alpha = 0
    scene.addChild(shootingStar)

    let waitAction = SKAction.wait(forDuration: TimeInterval.random(in: 3...6))
    let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
    let streak = SKAction.moveBy(x: size.width + 20, y: -size.height * 0.3, duration: 0.4)
    let fade = SKAction.fadeAlpha(to: 0, duration: 0.05)
    let reset = SKAction.run {
        shootingStar.position = CGPoint(
            x: CGFloat.random(in: -10...size.width * 0.3),
            y: CGFloat.random(in: size.height * 0.6...size.height)
        )
    }
    let nextWait = SKAction.wait(forDuration: TimeInterval.random(in: 3...6))
    shootingStar.run(SKAction.repeatForever(SKAction.sequence([waitAction, appear, streak, fade, reset, nextWait])))
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/SpaceEnvironmentRenderer.swift
git commit -m "feat: add Space buildPreviewBackground with stars, nebulae, shooting star"
```

---

### Task 8: Implement Underwater buildPreviewBackground

**Files:**
- Modify: `FlappyBird/Game/Environments/UnderwaterEnvironmentRenderer.swift`

**Step 1: Add `buildPreviewBackground` method**

Add after `buildBackground` (after line 88):

```swift
func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
    scene.backgroundColor = SKColor(red: 0.05, green: 0.1, blue: 0.4, alpha: 1)

    // Far layer: mini swaying seaweed (0.3x)
    var farNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        for j in 0..<3 {
            let seaweedHeight = CGFloat.random(in: 18...40)
            let seaweed = SKShapeNode(rectOf: CGSize(width: 2.5, height: seaweedHeight), cornerRadius: 1)
            seaweed.fillColor = SKColor(red: 0.1, green: CGFloat.random(in: 0.4...0.6), blue: 0.15, alpha: 0.7)
            seaweed.strokeColor = .clear
            seaweed.position = CGPoint(
                x: CGFloat(j) * size.width / 2 + CGFloat.random(in: 0...15),
                y: 8 + seaweedHeight / 2
            )
            container.addChild(seaweed)

            let swayRight = SKAction.rotate(byAngle: 0.08, duration: TimeInterval.random(in: 1.5...2.5))
            let swayLeft = SKAction.rotate(byAngle: -0.08, duration: TimeInterval.random(in: 1.5...2.5))
            seaweed.run(SKAction.repeatForever(SKAction.sequence([swayRight, swayLeft, swayLeft, swayRight])))
        }

        container.zPosition = -8
        scene.addChild(container)
        farNodes.append(container)
    }
    parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

    // Mid layer: mini light rays (0.6x)
    var midNodes: [SKNode] = []
    for i in 0..<2 {
        let container = SKNode()
        container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

        for j in 0..<2 {
            let rayPath = CGMutablePath()
            let baseX = CGFloat(j) * size.width / 1.5 + CGFloat.random(in: 10...25)
            rayPath.move(to: CGPoint(x: baseX, y: size.height))
            rayPath.addLine(to: CGPoint(x: baseX - 10, y: 0))
            rayPath.addLine(to: CGPoint(x: baseX + 5, y: 0))
            rayPath.addLine(to: CGPoint(x: baseX + 8, y: size.height))
            rayPath.closeSubpath()

            let ray = SKShapeNode(path: rayPath)
            ray.fillColor = SKColor(white: 1.0, alpha: 0.06)
            ray.strokeColor = .clear
            container.addChild(ray)
        }

        container.zPosition = -6
        scene.addChild(container)
        midNodes.append(container)
    }
    parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)

    // Animated: mini bubbles
    for _ in 0..<3 {
        let bubble = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
        bubble.fillColor = SKColor(white: 1.0, alpha: 0.4)
        bubble.strokeColor = SKColor(white: 1.0, alpha: 0.6)
        bubble.lineWidth = 0.3
        bubble.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height * 0.3)
        )
        bubble.zPosition = -4
        scene.addChild(bubble)

        let floatUp = SKAction.moveBy(x: CGFloat.random(in: -5...5), y: size.height + 10, duration: TimeInterval.random(in: 5...10))
        let reset = SKAction.run {
            bubble.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: -5
            )
        }
        bubble.run(SKAction.repeatForever(SKAction.sequence([floatUp, reset])))
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/UnderwaterEnvironmentRenderer.swift
git commit -m "feat: add Underwater buildPreviewBackground with seaweed, rays, bubbles"
```

---

### Task 9: Update EnvironmentSelectionView to Use Live Previews

**Files:**
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift`

**Step 1: Replace the grid and card implementation**

Replace the `LazyVGrid` from 3-column static to 2-column live previews. The full updated `environmentCard` method and grid:

In `EnvironmentSelectionView.swift`, replace the `LazyVGrid` block (lines 20-34) with:

```swift
LazyVGrid(columns: [
    GridItem(.flexible()),
    GridItem(.flexible())
], spacing: 16) {
    ForEach(GameEnvironment.allCases) { environment in
        environmentCard(environment: environment, isSelected: selectedEnvironment == environment)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedEnvironment = environment
                    router.selectEnvironment(environment)
                }
            }
    }
}
```

Replace the `environmentCard` method (lines 76-109) with:

```swift
private func environmentCard(environment: GameEnvironment, isSelected: Bool) -> some View {
    VStack(spacing: 8) {
        LiveEnvironmentPreview(environment: environment)

        Text(environment.displayName)
            .font(.headline)
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 12)
    .scaleEffect(isSelected ? 1.05 : 1.0)
}
```

**Step 2: Build and run the project**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: Build SUCCEEDS

**Step 3: Commit**

```bash
git add FlappyBird/Views/EnvironmentSelectionView.swift
git commit -m "feat: use live animated environment previews in selection cards"
```

---

### Task 10: Build Verification and Cleanup

**Files:**
- Check: All modified files compile
- Optional cleanup: Remove `EnvironmentPreviewRenderer` if no longer used elsewhere

**Step 1: Full build verification**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -10`

Expected: BUILD SUCCEEDED

**Step 2: Check if `EnvironmentPreviewRenderer` is used elsewhere**

Search for `EnvironmentPreviewRenderer` usage outside of `EnvironmentSelectionView.swift`. If only used there (and we replaced it), it can be removed from `EnvironmentRenderer.swift:25-45`. If used elsewhere, keep it.

**Step 3: Commit any cleanup**

```bash
git add -A
git commit -m "chore: remove unused EnvironmentPreviewRenderer"
```
