import SpriteKit

class UnderwaterEnvironmentRenderer: EnvironmentRenderer {

    // MARK: - Background

    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
        scene.backgroundColor = SKColor(red: 0.05, green: 0.1, blue: 0.4, alpha: 1)

        // Far layer: swaying seaweed strands (0.3x)
        var farNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            for j in 0..<5 {
                let seaweedHeight = CGFloat.random(in: 60...140)
                let seaweed = SKShapeNode(rectOf: CGSize(width: 6, height: seaweedHeight), cornerRadius: 3)
                seaweed.fillColor = SKColor(red: 0.1, green: CGFloat.random(in: 0.4...0.6), blue: 0.15, alpha: 0.7)
                seaweed.strokeColor = .clear
                seaweed.position = CGPoint(
                    x: CGFloat(j) * size.width / 4 + CGFloat.random(in: 0...30),
                    y: 40 + seaweedHeight / 2
                )
                container.addChild(seaweed)

                // Gentle sway animation
                let swayRight = SKAction.rotate(byAngle: 0.1, duration: TimeInterval.random(in: 1.5...2.5))
                let swayLeft = SKAction.rotate(byAngle: -0.1, duration: TimeInterval.random(in: 1.5...2.5))
                seaweed.run(SKAction.repeatForever(SKAction.sequence([swayRight, swayLeft, swayLeft, swayRight])))
            }

            container.zPosition = -8
            scene.addChild(container)
            farNodes.append(container)
        }
        parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

        // Mid layer: light rays (0.6x)
        var midNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            for j in 0..<3 {
                let rayPath = CGMutablePath()
                let baseX = CGFloat(j) * size.width / 2 + CGFloat.random(in: 20...60)
                rayPath.move(to: CGPoint(x: baseX, y: size.height))
                rayPath.addLine(to: CGPoint(x: baseX - 30, y: 0))
                rayPath.addLine(to: CGPoint(x: baseX + 15, y: 0))
                rayPath.addLine(to: CGPoint(x: baseX + 20, y: size.height))
                rayPath.closeSubpath()

                let ray = SKShapeNode(path: rayPath)
                ray.fillColor = SKColor(white: 1.0, alpha: 0.08)
                ray.strokeColor = .clear
                container.addChild(ray)
            }

            container.zPosition = -6
            scene.addChild(container)
            midNodes.append(container)
        }
        parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)

        // Animated: bubbles
        for _ in 0..<5 {
            let bubble = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            bubble.fillColor = SKColor(white: 1.0, alpha: 0.4)
            bubble.strokeColor = SKColor(white: 1.0, alpha: 0.6)
            bubble.lineWidth = 0.5
            bubble.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height * 0.3)
            )
            bubble.zPosition = -4
            scene.addChild(bubble)

            let floatUp = SKAction.moveBy(x: CGFloat.random(in: -15...15), y: size.height + 20, duration: TimeInterval.random(in: 6...12))
            let reset = SKAction.run {
                bubble.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -10
                )
            }
            bubble.run(SKAction.repeatForever(SKAction.sequence([floatUp, reset])))
        }
    }

    // MARK: - Obstacle

    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode {
        let container = SKNode()
        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2
        let coralColor = SKColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1)
        let coralStroke = SKColor(red: 0.7, green: 0.2, blue: 0.3, alpha: 1)

        // Top coral
        let topHeight = sceneHeight - gapTop
        if topHeight > 0 {
            let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: topHeight), cornerRadius: 4)
            topPipe.fillColor = coralColor
            topPipe.strokeColor = coralStroke
            topPipe.lineWidth = 2
            topPipe.position = CGPoint(x: 0, y: gapTop + topHeight / 2)
            topPipe.name = "obstacle"
            topPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topHeight))
            topPipe.physicsBody?.isDynamic = false
            topPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topPipe)

            // Bumpy coral edges
            for _ in 0..<5 {
                let bumpRadius = CGFloat.random(in: 6...10)
                let bumpY = CGFloat.random(in: gapTop + bumpRadius...sceneHeight - bumpRadius)
                let side: CGFloat = Bool.random() ? 1 : -1
                let bump = SKShapeNode(circleOfRadius: bumpRadius)
                bump.fillColor = coralColor
                bump.strokeColor = coralStroke
                bump.lineWidth = 1
                bump.position = CGPoint(x: side * pipeWidth / 2, y: bumpY)
                container.addChild(bump)
            }

            // Barnacles
            for _ in 0..<3 {
                let barnacle = SKShapeNode(circleOfRadius: 2)
                barnacle.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 0.8)
                barnacle.strokeColor = .clear
                barnacle.position = CGPoint(
                    x: CGFloat.random(in: -pipeWidth / 3...pipeWidth / 3),
                    y: CGFloat.random(in: gapTop + 10...max(gapTop + 11, sceneHeight - 10))
                )
                container.addChild(barnacle)
            }

            // Cap: coral head
            let capSize = CGSize(width: pipeWidth + 12, height: 18)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 9)
            topCap.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 1)
            topCap.strokeColor = coralStroke
            topCap.lineWidth = 2
            topCap.position = CGPoint(x: 0, y: gapTop + 9)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topCap)
        }

        // Bottom coral
        if gapBottom > 0 {
            let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: gapBottom), cornerRadius: 4)
            bottomPipe.fillColor = coralColor
            bottomPipe.strokeColor = coralStroke
            bottomPipe.lineWidth = 2
            bottomPipe.position = CGPoint(x: 0, y: gapBottom / 2)
            bottomPipe.name = "obstacle"
            bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
            bottomPipe.physicsBody?.isDynamic = false
            bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomPipe)

            // Bumpy coral edges
            for _ in 0..<4 {
                let bumpRadius = CGFloat.random(in: 6...10)
                let bumpY = CGFloat.random(in: bumpRadius...max(bumpRadius + 1, gapBottom - bumpRadius))
                let side: CGFloat = Bool.random() ? 1 : -1
                let bump = SKShapeNode(circleOfRadius: bumpRadius)
                bump.fillColor = coralColor
                bump.strokeColor = coralStroke
                bump.lineWidth = 1
                bump.position = CGPoint(x: side * pipeWidth / 2, y: bumpY)
                container.addChild(bump)
            }

            // Barnacles
            for _ in 0..<2 {
                let barnacle = SKShapeNode(circleOfRadius: 2)
                barnacle.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 0.8)
                barnacle.strokeColor = .clear
                barnacle.position = CGPoint(
                    x: CGFloat.random(in: -pipeWidth / 3...pipeWidth / 3),
                    y: CGFloat.random(in: 10...max(11, gapBottom - 10))
                )
                container.addChild(barnacle)
            }

            // Cap: coral head
            let capSize = CGSize(width: pipeWidth + 12, height: 18)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 9)
            bottomCap.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 1)
            bottomCap.strokeColor = coralStroke
            bottomCap.lineWidth = 2
            bottomCap.position = CGPoint(x: 0, y: gapBottom - 9)
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

        // Sandy ocean floor
        let ground = SKShapeNode(rectOf: size)
        ground.fillColor = SKColor(red: 0.76, green: 0.7, blue: 0.5, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(ground)

        // Small rocks
        for _ in 0..<4 {
            let x = CGFloat.random(in: 10...(size.width - 10))
            let rock = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 6...10), height: CGFloat.random(in: 4...6)))
            rock.fillColor = SKColor(red: 0.4, green: 0.38, blue: 0.32, alpha: 0.7)
            rock.strokeColor = .clear
            rock.position = CGPoint(x: x, y: size.height * 0.4)
            container.addChild(rock)
        }

        // Seaweed tufts growing up
        for _ in 0..<3 {
            let x = CGFloat.random(in: 15...(size.width - 15))
            let tuftPath = CGMutablePath()
            tuftPath.move(to: CGPoint(x: x - 3, y: size.height))
            tuftPath.addLine(to: CGPoint(x: x, y: size.height + 10))
            tuftPath.addLine(to: CGPoint(x: x + 3, y: size.height))
            tuftPath.closeSubpath()
            let tuft = SKShapeNode(path: tuftPath)
            tuft.fillColor = SKColor(red: 0.1, green: 0.5, blue: 0.15, alpha: 0.6)
            tuft.strokeColor = .clear
            container.addChild(tuft)
        }

        return container
    }

    // MARK: - Preview

    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = SKColor(red: 0.05, green: 0.1, blue: 0.4, alpha: 1)

        // Mini seaweed
        let seaweed = SKShapeNode(rectOf: CGSize(width: 3, height: 20), cornerRadius: 1)
        seaweed.fillColor = SKColor(red: 0.1, green: 0.5, blue: 0.15, alpha: 0.7)
        seaweed.strokeColor = .clear
        seaweed.position = CGPoint(x: size.width * 0.25, y: 20)
        scene.addChild(seaweed)

        // Mini coral
        let coral = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 3)
        coral.fillColor = SKColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1)
        coral.strokeColor = .clear
        coral.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        scene.addChild(coral)

        // Mini bubble
        let bubble = SKShapeNode(circleOfRadius: 3)
        bubble.fillColor = SKColor(white: 1.0, alpha: 0.4)
        bubble.strokeColor = SKColor(white: 1.0, alpha: 0.6)
        bubble.lineWidth = 0.5
        bubble.position = CGPoint(x: size.width * 0.4, y: size.height * 0.7)
        scene.addChild(bubble)

        // Mini ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        ground.fillColor = SKColor(red: 0.76, green: 0.7, blue: 0.5, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 5)
        scene.addChild(ground)

        return scene
    }
}
