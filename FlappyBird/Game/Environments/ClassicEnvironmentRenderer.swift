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
