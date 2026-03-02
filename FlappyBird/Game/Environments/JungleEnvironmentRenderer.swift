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
