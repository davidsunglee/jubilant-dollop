# Environment Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace flat-color environments with richly themed scenes featuring multi-layer parallax backgrounds, custom obstacle shapes, themed ground strips, and animated elements per environment.

**Architecture:** An `EnvironmentRenderer` protocol with 6 conforming classes (one per environment). `ParallaxBackground` upgraded to support multiple layers at different scroll speeds. `PipeNode` replaced by `ObstacleNode` that delegates visual construction to the renderer. `GameScene` and spawning logic updated to use renderers.

**Tech Stack:** SpriteKit (SKShapeNode, SKSpriteNode, SKAction, CGMutablePath), SwiftUI, cross-platform (iOS/macOS)

---

### Task 1: Upgrade ParallaxBackground to support multiple layers

**Files:**
- Modify: `FlappyBird/Game/ParallaxBackground.swift`

**Step 1: Rewrite ParallaxBackground with multi-layer support**

Replace the entire file with:

```swift
import SpriteKit

struct ParallaxLayer {
    let nodes: [SKNode]
    let speedMultiplier: CGFloat
    let width: CGFloat
}

class ParallaxBackground {
    private var layers: [ParallaxLayer] = []
    private let baseSpeed: CGFloat

    init(baseSpeed: CGFloat = 150) {
        self.baseSpeed = baseSpeed
    }

    func addLayer(nodes: [SKNode], speedMultiplier: CGFloat, width: CGFloat) {
        let layer = ParallaxLayer(nodes: nodes, speedMultiplier: speedMultiplier, width: width)
        layers.append(layer)
    }

    func update(deltaTime: TimeInterval) {
        for layer in layers {
            let speed = baseSpeed * layer.speedMultiplier
            for node in layer.nodes {
                node.position.x -= speed * CGFloat(deltaTime)

                if node.position.x + layer.width <= 0 {
                    let maxX = layer.nodes.map { $0.position.x }.max() ?? 0
                    node.position.x = maxX + layer.width
                }
            }
        }
    }

    func removeFromParent() {
        for layer in layers {
            for node in layer.nodes {
                node.removeFromParent()
            }
        }
        layers.removeAll()
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/ParallaxBackground.swift
git commit -m "refactor: upgrade ParallaxBackground to support multiple layers with speed multipliers

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 2: Create EnvironmentRenderer protocol and factory

**Files:**
- Create: `FlappyBird/Game/EnvironmentRenderer.swift`
- Modify: `FlappyBird/Models/GameEnvironment.swift`

**Step 1: Create the protocol file**

Create `FlappyBird/Game/EnvironmentRenderer.swift`:

```swift
import SpriteKit

protocol EnvironmentRenderer {
    /// Build background layers (gradient sky, scenery, animated elements).
    /// Returns nodes that should be added to the scene.
    /// Also sets up ParallaxBackground layers.
    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)

    /// Build a pair of obstacles (top + bottom) with gap.
    /// Returns an SKNode with physics bodies configured.
    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode

    /// Build the ground strip node for one parallax tile.
    func buildGroundTile(size: CGSize) -> SKNode

    /// Render a preview image for the environment selection screen.
    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene
}
```

**Step 2: Add renderer property to GameEnvironment**

In `FlappyBird/Models/GameEnvironment.swift`, add at the end of the enum (before the closing brace):

```swift
var renderer: EnvironmentRenderer {
    switch self {
    case .classic:    return ClassicEnvironmentRenderer()
    case .jungle:     return JungleEnvironmentRenderer()
    case .underwater: return UnderwaterEnvironmentRenderer()
    case .arctic:     return ArcticEnvironmentRenderer()
    case .desert:     return DesertEnvironmentRenderer()
    case .space:      return SpaceEnvironmentRenderer()
    }
}
```

**Step 3: Commit**

```bash
git add FlappyBird/Game/EnvironmentRenderer.swift FlappyBird/Models/GameEnvironment.swift
git commit -m "feat: create EnvironmentRenderer protocol and factory on GameEnvironment

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 3: Replace PipeNode with ObstacleNode

**Files:**
- Create: `FlappyBird/Game/ObstacleNode.swift`
- Delete: `FlappyBird/Game/PipeNode.swift`
- Modify: `FlappyBird/Game/GameScene+Spawning.swift`

**Step 1: Create ObstacleNode**

Create `FlappyBird/Game/ObstacleNode.swift`. This is a thin wrapper — the renderer builds the visuals, but ObstacleNode owns the score zone and container:

```swift
import SpriteKit

class ObstacleNode: SKNode {
    init(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat, renderer: EnvironmentRenderer) {
        super.init()
        name = "pipePair"

        // Delegate visual + physics construction to the renderer
        let visual = renderer.buildObstacle(
            sceneHeight: sceneHeight,
            gapCenterY: gapCenterY,
            gapHeight: gapHeight,
            pipeWidth: pipeWidth
        )

        // The renderer returns a node with obstacle children already configured
        for child in visual.children {
            let detached = child
            detached.removeFromParent()
            addChild(detached)
        }

        // Score zone (invisible, in the gap) — always the same regardless of environment
        let scoreZone = SKNode()
        scoreZone.position = CGPoint(x: 0, y: gapCenterY)
        scoreZone.name = "scoreZone"
        scoreZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: gapHeight))
        scoreZone.physicsBody?.isDynamic = false
        scoreZone.physicsBody?.categoryBitMask = PhysicsCategory.scoreZone
        scoreZone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        scoreZone.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(scoreZone)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

**Step 2: Update GameScene+Spawning to use ObstacleNode**

Replace `spawnPipePair()` in `FlappyBird/Game/GameScene+Spawning.swift`:

```swift
import SpriteKit

// MARK: - Pipe Spawning
extension GameScene {

    func startSpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnPipePair()
        }
        let delay = SKAction.wait(forDuration: pipeSpawnInterval)
        let spawnSequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawning")
    }

    func spawnPipePair() {
        guard size.width > 0, size.height > 0 else { return }

        let minY = size.height * 0.2
        let maxY = size.height * 0.8
        let randomGapY = CGFloat.random(in: minY...maxY)

        let obstacle = ObstacleNode(
            sceneHeight: size.height,
            gapCenterY: randomGapY,
            gapHeight: gapHeight,
            pipeWidth: pipeWidth,
            renderer: router.config.environment.renderer
        )

        obstacle.position = CGPoint(x: size.width + pipeWidth, y: 0)
        obstacle.zPosition = 1
        addChild(obstacle)

        let distance = size.width + pipeWidth * 2
        let duration = TimeInterval(distance / pipeSpeed)
        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }
}
```

**Step 3: Delete PipeNode.swift**

```bash
git rm FlappyBird/Game/PipeNode.swift
```

**Step 4: Commit**

```bash
git add FlappyBird/Game/ObstacleNode.swift FlappyBird/Game/GameScene+Spawning.swift
git commit -m "feat: replace PipeNode with ObstacleNode using EnvironmentRenderer

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 4: Update GameScene to use EnvironmentRenderer for background and ground

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift`

**Step 1: Update setupBackground to use renderer**

Replace the `setupBackground()` method in GameScene.swift with:

```swift
private func setupBackground() {
    let renderer = router.config.environment.renderer
    parallaxBackground = ParallaxBackground(baseSpeed: pipeSpeed)

    // Let the renderer build all background layers (gradient, scenery, animated elements)
    renderer.buildBackground(scene: self, size: size, parallax: parallaxBackground!)

    // Build ground layer via renderer
    let groundSize = CGSize(width: size.width, height: 40)
    for i in 0..<2 {
        let groundTile = renderer.buildGroundTile(size: groundSize)
        groundTile.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
        groundTile.zPosition = 2
        addChild(groundTile)
        if i == 0 {
            parallaxBackground?.addLayer(nodes: [], speedMultiplier: 1.0, width: size.width)
        }
    }
    // Re-add ground nodes to the last layer properly
    // Actually, build ground tiles and add to parallax as a layer:
}
```

Wait — let me reconsider this. The ground tiles need to be tracked by `ParallaxBackground` as a layer. Let me write the cleaner version:

```swift
private func setupBackground() {
    let renderer = router.config.environment.renderer
    parallaxBackground = ParallaxBackground(baseSpeed: pipeSpeed)

    // Build background layers (gradient sky, scenery, animated elements)
    renderer.buildBackground(scene: self, size: size, parallax: parallaxBackground!)

    // Build ground as a parallax layer (1.0x speed, synced with obstacles)
    let groundSize = CGSize(width: size.width, height: 40)
    var groundNodes: [SKNode] = []
    for i in 0..<2 {
        let groundTile = renderer.buildGroundTile(size: groundSize)
        groundTile.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
        groundTile.zPosition = 2
        addChild(groundTile)
        groundNodes.append(groundTile)
    }
    parallaxBackground?.addLayer(nodes: groundNodes, speedMultiplier: 1.0, width: size.width)
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/GameScene.swift
git commit -m "refactor: update GameScene to use EnvironmentRenderer for background and ground

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 5: Build ClassicEnvironmentRenderer

**Files:**
- Create: `FlappyBird/Game/Environments/ClassicEnvironmentRenderer.swift`

**Step 1: Create the file**

```swift
import SpriteKit

class ClassicEnvironmentRenderer: EnvironmentRenderer {

    // MARK: - Background

    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
        // Sky gradient - light blue
        scene.backgroundColor = .cyan

        // Far layer: rolling green hills (0.3x speed)
        var farNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            // Hills - overlapping green semicircles along the bottom
            let hillPositions: [(x: CGFloat, radius: CGFloat)] = [
                (size.width * 0.15, 60),
                (size.width * 0.4, 80),
                (size.width * 0.65, 55),
                (size.width * 0.85, 70),
            ]
            for hp in hillPositions {
                let hill = SKShapeNode(circleOfRadius: hp.radius)
                hill.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
                hill.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 0.2, alpha: 1)
                hill.lineWidth = 1
                hill.position = CGPoint(x: hp.x, y: 40 + hp.radius * 0.3)
                container.addChild(hill)
            }

            container.zPosition = -8
            scene.addChild(container)
            farNodes.append(container)
        }
        parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

        // Mid layer: white fluffy clouds (0.5x speed)
        var midNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            let cloudPositions: [(x: CGFloat, y: CGFloat, scale: CGFloat)] = [
                (size.width * 0.2, size.height * 0.75, 1.0),
                (size.width * 0.6, size.height * 0.85, 0.7),
                (size.width * 0.8, size.height * 0.65, 0.9),
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

        // Animated: drifting birds (2-3 small dots)
        for _ in 0..<3 {
            let bird = SKShapeNode(circleOfRadius: 2)
            bird.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.6)
            bird.strokeColor = .clear
            bird.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.6...size.height * 0.9)
            )
            bird.zPosition = -5
            scene.addChild(bird)

            let drift = SKAction.moveBy(x: -size.width - 50, y: CGFloat.random(in: -20...20), duration: TimeInterval.random(in: 12...18))
            let reset = SKAction.run {
                bird.position = CGPoint(
                    x: size.width + 20,
                    y: CGFloat.random(in: size.height * 0.6...size.height * 0.9)
                )
            }
            bird.run(SKAction.repeatForever(SKAction.sequence([drift, reset])))
        }
    }

    private func buildCloud(scale: CGFloat) -> SKNode {
        let cloud = SKNode()
        let positions: [(x: CGFloat, y: CGFloat, r: CGFloat)] = [
            (0, 0, 18), (-14, -2, 14), (14, -2, 14), (-7, 6, 12), (7, 6, 12)
        ]
        for p in positions {
            let puff = SKShapeNode(circleOfRadius: p.r * scale)
            puff.fillColor = SKColor(white: 1.0, alpha: 0.9)
            puff.strokeColor = .clear
            puff.position = CGPoint(x: p.x * scale, y: p.y * scale)
            cloud.addChild(puff)
        }
        return cloud
    }

    // MARK: - Obstacle

    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode {
        let container = SKNode()

        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2

        // Top pipe
        let topPipeHeight = sceneHeight - gapTop
        if topPipeHeight > 0 {
            let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: topPipeHeight), cornerRadius: 4)
            topPipe.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1)
            topPipe.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1)
            topPipe.lineWidth = 2
            topPipe.position = CGPoint(x: 0, y: gapTop + topPipeHeight / 2)
            topPipe.name = "obstacle"
            topPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topPipeHeight))
            topPipe.physicsBody?.isDynamic = false
            topPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topPipe)

            // Highlight stripe
            let stripe = SKShapeNode(rectOf: CGSize(width: 4, height: topPipeHeight - 4))
            stripe.fillColor = SKColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 0.4)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: -pipeWidth * 0.15, y: gapTop + topPipeHeight / 2)
            container.addChild(stripe)

            // Cap
            let capSize = CGSize(width: pipeWidth + 10, height: 20)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 6)
            topCap.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1)
            topCap.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1)
            topCap.lineWidth = 2
            topCap.position = CGPoint(x: 0, y: gapTop + 10)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topCap)
        }

        // Bottom pipe
        if gapBottom > 0 {
            let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: gapBottom), cornerRadius: 4)
            bottomPipe.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1)
            bottomPipe.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1)
            bottomPipe.lineWidth = 2
            bottomPipe.position = CGPoint(x: 0, y: gapBottom / 2)
            bottomPipe.name = "obstacle"
            bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
            bottomPipe.physicsBody?.isDynamic = false
            bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomPipe)

            // Highlight stripe
            let stripe = SKShapeNode(rectOf: CGSize(width: 4, height: gapBottom - 4))
            stripe.fillColor = SKColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 0.4)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: -pipeWidth * 0.15, y: gapBottom / 2)
            container.addChild(stripe)

            // Cap
            let capSize = CGSize(width: pipeWidth + 10, height: 20)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 6)
            bottomCap.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1)
            bottomCap.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1)
            bottomCap.lineWidth = 2
            bottomCap.position = CGPoint(x: 0, y: gapBottom - 10)
            bottomCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            bottomCap.physicsBody?.isDynamic = false
            bottomCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomCap)
        }

        return container
    }

    // MARK: - Ground

    func buildGroundTile(size: CGSize) -> SKNode {
        let container = SKNode()

        // Base brown ground
        let ground = SKShapeNode(rectOf: size)
        ground.fillColor = SKColor(red: 0.86, green: 0.69, blue: 0.35, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(ground)

        // Green grass line on top
        let grass = SKShapeNode(rectOf: CGSize(width: size.width, height: 4))
        grass.fillColor = SKColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 1)
        grass.strokeColor = .clear
        grass.position = CGPoint(x: size.width / 2, y: size.height - 2)
        container.addChild(grass)

        // Grass tufts
        for _ in 0..<8 {
            let x = CGFloat.random(in: 10...(size.width - 10))
            let tuftPath = CGMutablePath()
            tuftPath.move(to: CGPoint(x: x - 2, y: size.height))
            tuftPath.addLine(to: CGPoint(x: x, y: size.height + 5))
            tuftPath.addLine(to: CGPoint(x: x + 2, y: size.height))
            tuftPath.closeSubpath()
            let tuft = SKShapeNode(path: tuftPath)
            tuft.fillColor = SKColor(red: 0.25, green: 0.6, blue: 0.15, alpha: 1)
            tuft.strokeColor = .clear
            container.addChild(tuft)
        }

        return container
    }

    // MARK: - Preview

    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = .cyan

        // Mini hills
        let hill = SKShapeNode(circleOfRadius: 20)
        hill.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
        hill.strokeColor = .clear
        hill.position = CGPoint(x: size.width * 0.5, y: 18)
        scene.addChild(hill)

        // Mini cloud
        let cloud = SKShapeNode(circleOfRadius: 8)
        cloud.fillColor = .white
        cloud.strokeColor = .clear
        cloud.position = CGPoint(x: size.width * 0.3, y: size.height * 0.7)
        scene.addChild(cloud)

        // Mini pipe
        let pipe = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 2)
        pipe.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1)
        pipe.strokeColor = .clear
        pipe.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        scene.addChild(pipe)

        // Mini ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        ground.fillColor = SKColor(red: 0.86, green: 0.69, blue: 0.35, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 5)
        scene.addChild(ground)

        return scene
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/ClassicEnvironmentRenderer.swift
git commit -m "feat: build Classic environment with clouds, hills, green pipes

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 6: Build JungleEnvironmentRenderer

**Files:**
- Create: `FlappyBird/Game/Environments/JungleEnvironmentRenderer.swift`

**Step 1: Create the file**

```swift
import SpriteKit

class JungleEnvironmentRenderer: EnvironmentRenderer {

    // MARK: - Background

    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
        scene.backgroundColor = .systemGreen

        // Far layer: dense canopy (0.3x)
        var farNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            // Dark green canopy circles at top
            for j in 0..<6 {
                let canopy = SKShapeNode(circleOfRadius: CGFloat.random(in: 40...70))
                canopy.fillColor = SKColor(red: 0.05, green: CGFloat.random(in: 0.3...0.45), blue: 0.05, alpha: 0.8)
                canopy.strokeColor = .clear
                canopy.position = CGPoint(
                    x: CGFloat(j) * size.width / 5,
                    y: size.height - CGFloat.random(in: 10...50)
                )
                container.addChild(canopy)
            }

            container.zPosition = -8
            scene.addChild(container)
            farNodes.append(container)
        }
        parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

        // Mid layer: hanging vines (0.6x)
        var midNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            for j in 0..<4 {
                let vineHeight = CGFloat.random(in: 40...120)
                let vine = SKShapeNode(rectOf: CGSize(width: 3, height: vineHeight), cornerRadius: 1)
                vine.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.1, alpha: 0.7)
                vine.strokeColor = .clear
                vine.position = CGPoint(
                    x: CGFloat(j) * size.width / 3 + CGFloat.random(in: 0...40),
                    y: size.height - vineHeight / 2
                )
                container.addChild(vine)

                // Small leaf at vine tip
                let leaf = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
                leaf.fillColor = SKColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 0.8)
                leaf.strokeColor = .clear
                leaf.position = CGPoint(x: vine.position.x, y: size.height - vineHeight - 2)
                container.addChild(leaf)
            }

            container.zPosition = -6
            scene.addChild(container)
            midNodes.append(container)
        }
        parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)

        // Animated: fireflies
        for _ in 0..<4 {
            let firefly = SKShapeNode(circleOfRadius: 2)
            firefly.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1)
            firefly.strokeColor = .clear
            firefly.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.3...size.height * 0.8)
            )
            firefly.zPosition = -4
            firefly.alpha = 0.3
            scene.addChild(firefly)

            let glow = SKAction.fadeAlpha(to: 1.0, duration: TimeInterval.random(in: 0.8...1.5))
            let dim = SKAction.fadeAlpha(to: 0.2, duration: TimeInterval.random(in: 0.8...1.5))
            let drift = SKAction.moveBy(
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -20...20),
                duration: 3.0
            )
            let driftBack = drift.reversed()
            firefly.run(SKAction.repeatForever(SKAction.sequence([glow, dim])))
            firefly.run(SKAction.repeatForever(SKAction.sequence([drift, driftBack])))
        }
    }

    // MARK: - Obstacle

    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode {
        let container = SKNode()
        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2
        let bambooColor = SKColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1)
        let bambooStroke = SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1)

        // Top bamboo
        let topHeight = sceneHeight - gapTop
        if topHeight > 0 {
            let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: topHeight), cornerRadius: 3)
            topPipe.fillColor = bambooColor
            topPipe.strokeColor = bambooStroke
            topPipe.lineWidth = 2
            topPipe.position = CGPoint(x: 0, y: gapTop + topHeight / 2)
            topPipe.name = "obstacle"
            topPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topHeight))
            topPipe.physicsBody?.isDynamic = false
            topPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topPipe)

            // Bamboo joints
            let jointCount = Int(topHeight / 30)
            for j in 0..<jointCount {
                let jointY = gapTop + CGFloat(j) * 30 + 15
                let joint = SKShapeNode(rectOf: CGSize(width: pipeWidth + 4, height: 3), cornerRadius: 1)
                joint.fillColor = bambooStroke
                joint.strokeColor = .clear
                joint.position = CGPoint(x: 0, y: jointY)
                container.addChild(joint)

                // Leaf at some joints
                if j % 2 == 0 {
                    let leaf = SKShapeNode(ellipseOf: CGSize(width: 12, height: 5))
                    leaf.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.15, alpha: 0.8)
                    leaf.strokeColor = .clear
                    leaf.position = CGPoint(x: pipeWidth / 2 + 4, y: jointY)
                    leaf.zRotation = 0.3
                    container.addChild(leaf)
                }
            }

            // Cap - thicker bamboo node
            let capSize = CGSize(width: pipeWidth + 8, height: 16)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 4)
            topCap.fillColor = bambooColor
            topCap.strokeColor = bambooStroke
            topCap.lineWidth = 2
            topCap.position = CGPoint(x: 0, y: gapTop + 8)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topCap)
        }

        // Bottom bamboo
        if gapBottom > 0 {
            let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: gapBottom), cornerRadius: 3)
            bottomPipe.fillColor = bambooColor
            bottomPipe.strokeColor = bambooStroke
            bottomPipe.lineWidth = 2
            bottomPipe.position = CGPoint(x: 0, y: gapBottom / 2)
            bottomPipe.name = "obstacle"
            bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
            bottomPipe.physicsBody?.isDynamic = false
            bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomPipe)

            // Bamboo joints
            let jointCount = Int(gapBottom / 30)
            for j in 0..<jointCount {
                let jointY = CGFloat(j) * 30 + 15
                let joint = SKShapeNode(rectOf: CGSize(width: pipeWidth + 4, height: 3), cornerRadius: 1)
                joint.fillColor = bambooStroke
                joint.strokeColor = .clear
                joint.position = CGPoint(x: 0, y: jointY)
                container.addChild(joint)
            }

            // Cap
            let capSize = CGSize(width: pipeWidth + 8, height: 16)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 4)
            bottomCap.fillColor = bambooColor
            bottomCap.strokeColor = bambooStroke
            bottomCap.lineWidth = 2
            bottomCap.position = CGPoint(x: 0, y: gapBottom - 8)
            bottomCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            bottomCap.physicsBody?.isDynamic = false
            bottomCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomCap)
        }

        return container
    }

    // MARK: - Ground

    func buildGroundTile(size: CGSize) -> SKNode {
        let container = SKNode()

        let ground = SKShapeNode(rectOf: size)
        ground.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(ground)

        // Roots along top
        for _ in 0..<5 {
            let x = CGFloat.random(in: 10...(size.width - 10))
            let root = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 6...12)), cornerRadius: 1)
            root.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.7)
            root.strokeColor = .clear
            root.position = CGPoint(x: x, y: size.height - 3)
            root.zRotation = CGFloat.random(in: -0.3...0.3)
            container.addChild(root)
        }

        // Small mushrooms
        for _ in 0..<2 {
            let x = CGFloat.random(in: 20...(size.width - 20))
            let stem = SKShapeNode(rectOf: CGSize(width: 2, height: 5))
            stem.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1)
            stem.strokeColor = .clear
            stem.position = CGPoint(x: x, y: size.height + 2)
            container.addChild(stem)

            let cap = SKShapeNode(circleOfRadius: 4)
            cap.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.1, alpha: 1)
            cap.strokeColor = .clear
            cap.position = CGPoint(x: x, y: size.height + 6)
            container.addChild(cap)
        }

        return container
    }

    // MARK: - Preview

    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = .systemGreen

        // Mini canopy
        let canopy = SKShapeNode(circleOfRadius: 18)
        canopy.fillColor = SKColor(red: 0.05, green: 0.35, blue: 0.05, alpha: 0.8)
        canopy.strokeColor = .clear
        canopy.position = CGPoint(x: size.width * 0.4, y: size.height - 10)
        scene.addChild(canopy)

        // Mini vine
        let vine = SKShapeNode(rectOf: CGSize(width: 2, height: 25))
        vine.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.1, alpha: 0.7)
        vine.strokeColor = .clear
        vine.position = CGPoint(x: size.width * 0.3, y: size.height - 20)
        scene.addChild(vine)

        // Mini bamboo
        let bamboo = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 2)
        bamboo.fillColor = SKColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1)
        bamboo.strokeColor = .clear
        bamboo.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        scene.addChild(bamboo)

        // Mini ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        ground.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 5)
        scene.addChild(ground)

        return scene
    }
}
```

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/JungleEnvironmentRenderer.swift
git commit -m "feat: build Jungle environment with canopy, vines, fireflies, bamboo obstacles

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 7: Build UnderwaterEnvironmentRenderer

**Files:**
- Create: `FlappyBird/Game/Environments/UnderwaterEnvironmentRenderer.swift`

**Step 1: Create the file**

The implementer should follow the same pattern as Classic and Jungle. Key elements:

- **Background:** Dark navy (`SKColor(red: 0.05, green: 0.1, blue: 0.4, alpha: 1)`). Far layer (0.3x): swaying seaweed strands (tall thin green rectangles with gentle SKAction sway). Mid layer (0.6x): light rays (semi-transparent white elongated triangles angling from top-right to bottom-left). Animated: bubbles (4-5 small white/light-blue circles floating upward with slight horizontal wobble, respawning at bottom).
- **Obstacle:** Coral formations. Pink/red base color (`SKColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1)`). Bumpy edges: add 4-6 small circles (radius 6-10) along each side of the main rectangle at random Y positions to create irregular coral texture. Small barnacles: 2-3 tiny dark circles (radius 2) on the surface. Cap: rounded coral head (larger circle or wide rounded rect).
- **Ground:** Sandy ocean floor (tan/beige `SKColor(red: 0.76, green: 0.7, blue: 0.5, alpha: 1)`). Small rocks (dark ellipses) and seaweed tufts (thin green triangles growing up) scattered.
- **Preview:** Navy background, mini coral, mini seaweed, mini bubble, sandy ground.

The implementer must write the full Swift file following the `EnvironmentRenderer` protocol with all four methods (`buildBackground`, `buildObstacle`, `buildGroundTile`, `renderPreview`), using the same physics body patterns as Classic/Jungle (rectangle physics bodies with `PhysicsCategory.obstacle` bitmasks).

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/UnderwaterEnvironmentRenderer.swift
git commit -m "feat: build Underwater environment with seaweed, bubbles, light rays, coral obstacles

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 8: Build ArcticEnvironmentRenderer

**Files:**
- Create: `FlappyBird/Game/Environments/ArcticEnvironmentRenderer.swift`

**Step 1: Create the file**

Key elements:

- **Background:** Pale ice-blue (`SKColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1)`). Far layer (0.3x): snowy mountain silhouettes — triangles (white with light grey stroke, various sizes, positioned along the bottom portion). Mid layer (0.6x): snow drifts — white rounded humps (half-circles or wide ellipses). Animated: snowflakes (6-8 tiny white circles) falling downward with slight horizontal drift, respawning at top of screen.
- **Obstacle:** Ice pillars. Pale blue base (`SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1)`), white frost shapes (small irregular white rectangles/circles) along edges. Icicles: small downward-pointing triangles hanging from top obstacle's bottom edge, small upward-pointing triangles growing from bottom obstacle's top edge. Cap: white snow drift (wide rounded rectangle, white fill).
- **Ground:** White snow with subtle blue-grey ice layer beneath. Snow drift bumps (small white ellipses along top edge).
- **Preview:** Ice-blue background, mini mountain triangle, mini snowflake dots, mini ice pillar, white ground.

Full Swift file implementing `EnvironmentRenderer` protocol.

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/ArcticEnvironmentRenderer.swift
git commit -m "feat: build Arctic environment with mountains, snowflakes, ice pillars

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 9: Build DesertEnvironmentRenderer

**Files:**
- Create: `FlappyBird/Game/Environments/DesertEnvironmentRenderer.swift`

**Step 1: Create the file**

Key elements:

- **Background:** Warm sand-to-orange (`SKColor.systemYellow`). Far layer (0.3x): sand dunes — smooth curved shapes (wide ellipses or arc paths, sandy tan color) along the bottom half. Mid layer (0.6x): cactus silhouettes — simple T-shapes built from rectangles (dark green, 2-3 per tile). Animated: heat shimmer — apply a subtle vertical oscillation SKAction to the far parallax layer nodes (`moveBy(x:0, y:3)` and back, slow duration ~2s).
- **Obstacle:** Sandstone rock columns. Layered rectangles of slightly different widths (3 segments stacked) in tan/orange shades to create carved-rock look. Thin dark lines (crack shapes) drawn across surface. Cap: flat mesa top — wide thin rectangle with sharp corners, darker brown.
- **Ground:** Light sand (`SKColor(red: 0.9, green: 0.8, blue: 0.55, alpha: 1)`) with darker sand ripple lines (thin wavy horizontal shapes). Small rocks scattered.
- **Preview:** Yellow background, mini dune, mini cactus, mini sandstone column, sandy ground.

Full Swift file implementing `EnvironmentRenderer` protocol.

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/DesertEnvironmentRenderer.swift
git commit -m "feat: build Desert environment with dunes, cacti, heat shimmer, sandstone obstacles

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 10: Build SpaceEnvironmentRenderer

**Files:**
- Create: `FlappyBird/Game/Environments/SpaceEnvironmentRenderer.swift`

**Step 1: Create the file**

Key elements:

- **Background:** Black (`.black`). Static star field: scatter 30-40 small white/light-blue circles (radius 0.5-2) at random positions across the scene — these are added directly to the scene (not parallax, they stay fixed). Far layer (0.3x): distant nebula smudges — 2-3 large semi-transparent colored ellipses (purple, blue, pink, alpha 0.15-0.25). Animated: shooting stars — one node at a time. A small bright white elongated ellipse that streaks across quickly (SKAction.moveBy over ~0.5s), then fades, waits a random delay (3-8s), resets position, and repeats.
- **Obstacle:** Neon purple energy barriers. Base color `SKColor.purple`. Inner glow: a slightly smaller, brighter semi-transparent rectangle inside the main one (`alpha: 0.4`, lighter purple). Electrical sparks: 3-4 tiny bright white/yellow circles randomly placed along edges. Cap: pulsing glow — a wider rectangle with a repeating fade in/out SKAction on a brighter overlay.
- **Ground:** Dark purple metallic (`SKColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 1)`). Glowing neon edge line on top (thin bright purple rectangle). Small rivets: tiny light-grey circles at regular intervals.
- **Preview:** Black background, mini star dots, mini nebula smudge, mini purple barrier, dark ground with neon line.

Full Swift file implementing `EnvironmentRenderer` protocol.

**Step 2: Commit**

```bash
git add FlappyBird/Game/Environments/SpaceEnvironmentRenderer.swift
git commit -m "feat: build Space environment with stars, nebula, shooting stars, energy barriers

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 11: Update EnvironmentSelectionView with rendered previews

**Files:**
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift`
- Modify: `FlappyBird/Game/EnvironmentRenderer.swift` (add renderToImage helper)

**Step 1: Add renderToImage helper**

Add to `EnvironmentRenderer.swift`, outside the protocol (as a free function or extension):

```swift
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum EnvironmentPreviewRenderer {
    private static var cache: [GameEnvironment: CharacterRenderer.PlatformImage] = [:]

    static func renderToImage(for environment: GameEnvironment, size: CGSize = CGSize(width: 160, height: 80)) -> CharacterRenderer.PlatformImage? {
        if let cached = cache[environment] { return cached }

        let scene = environment.renderer.renderPreview(size: size, environment: environment)
        let view = SKView(frame: CGRect(origin: .zero, size: size))
        guard let texture = view.texture(from: scene) else { return nil }

        #if os(iOS)
        let image = UIImage(cgImage: texture.cgImage())
        #elseif os(macOS)
        let cgImage = texture.cgImage()
        let image = NSImage(cgImage: cgImage, size: size)
        #endif

        cache[environment] = image
        return image
    }
}
```

**Step 2: Update EnvironmentSelectionView**

Replace the `environmentCard` method:

```swift
private func environmentCard(environment: GameEnvironment) -> some View {
    VStack(spacing: 8) {
        Group {
            if let image = EnvironmentPreviewRenderer.renderToImage(for: environment, size: CGSize(width: 160, height: 80)) {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                #endif
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(environment.backgroundColor))
                    .frame(height: 80)
            }
        }

        Text(environment.displayName)
            .font(.headline)
    }
    .frame(width: 160, height: 130)
    .background(Color.white.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

**Step 3: Commit**

```bash
git add FlappyBird/Game/EnvironmentRenderer.swift FlappyBird/Views/EnvironmentSelectionView.swift
git commit -m "feat: update environment selection with rendered scene previews

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 12: Final integration and cleanup

**Files:**
- Modify: `FlappyBird/Models/GameEnvironment.swift` (verify/clean up unused properties)
- Verify: All files compile together

**Step 1: Clean up GameEnvironment**

The `backgroundColor`, `obstacleColor`, and `groundColor` properties on `GameEnvironment` may still be used by other parts of the code (e.g. `setupWorld()` in GameScene sets `scene.backgroundColor`). Check all references:

- `backgroundColor` is used in `GameScene.setupWorld()` — keep it, OR move that call into the renderer's `buildBackground` (which already sets `scene.backgroundColor`). If the renderer handles it, remove from GameEnvironment.
- `obstacleColor` was used by old PipeNode/spawning — now handled by renderer. Can be removed.
- `groundColor` was used by old ParallaxBackground — now handled by renderer. Can be removed.

Remove `obstacleColor` and `groundColor` from `GameEnvironment.swift`. Keep `backgroundColor` only if `setupWorld()` still references it; otherwise remove it too.

Update `GameScene.setupWorld()` to no longer set `backgroundColor` directly (the renderer does it in `buildBackground`):

```swift
private func setupWorld() {
    physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
    physicsWorld.contactDelegate = self
}
```

**Step 2: Verify no remaining references to PipeNode**

Search for any remaining `PipeNode` references and remove them.

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: clean up unused environment properties, remove PipeNode references

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```
