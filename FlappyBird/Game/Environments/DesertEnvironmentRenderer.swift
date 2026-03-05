import SpriteKit

class DesertEnvironmentRenderer: EnvironmentRenderer {

    // MARK: - Background

    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
        scene.backgroundColor = .systemYellow

        // Far layer: sand dunes (0.3x) with heat shimmer
        var farNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            let dunes: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
                (size.width * 0.15, 140, 45),
                (size.width * 0.4, 180, 60),
                (size.width * 0.7, 120, 35),
                (size.width * 0.9, 160, 50),
            ]
            for d in dunes {
                let dune = SKShapeNode(ellipseOf: CGSize(width: d.w, height: d.h))
                dune.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.5, alpha: 1)
                dune.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.45, alpha: 1)
                dune.lineWidth = 1
                dune.position = CGPoint(x: d.x, y: 40 + d.h * 0.3)
                container.addChild(dune)
            }

            container.zPosition = -8
            scene.addChild(container)
            farNodes.append(container)

            // Heat shimmer animation on far layer
            let shimmerUp = SKAction.moveBy(x: 0, y: 3, duration: 2.0)
            let shimmerDown = SKAction.moveBy(x: 0, y: -3, duration: 2.0)
            shimmerUp.timingMode = .easeInEaseOut
            shimmerDown.timingMode = .easeInEaseOut
            container.run(SKAction.repeatForever(SKAction.sequence([shimmerUp, shimmerDown])))
        }
        parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

        // Mid layer: cactus silhouettes (0.6x)
        var midNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            for j in 0..<3 {
                let cactus = buildCactus()
                cactus.position = CGPoint(
                    x: CGFloat(j) * size.width / 2 + CGFloat.random(in: 20...60),
                    y: 55
                )
                container.addChild(cactus)
            }

            container.zPosition = -6
            scene.addChild(container)
            midNodes.append(container)
        }
        parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)
    }

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

    private func buildCactus() -> SKNode {
        let cactus = SKNode()
        let cactusColor = SKColor(red: 0.15, green: 0.45, blue: 0.1, alpha: 0.8)

        // Main trunk
        let trunk = SKShapeNode(rectOf: CGSize(width: 10, height: 40), cornerRadius: 3)
        trunk.fillColor = cactusColor
        trunk.strokeColor = .clear
        trunk.position = CGPoint(x: 0, y: 20)
        cactus.addChild(trunk)

        // Left arm
        let leftArm = SKShapeNode(rectOf: CGSize(width: 8, height: 18), cornerRadius: 3)
        leftArm.fillColor = cactusColor
        leftArm.strokeColor = .clear
        leftArm.position = CGPoint(x: -12, y: 28)
        cactus.addChild(leftArm)

        let leftConnector = SKShapeNode(rectOf: CGSize(width: 8, height: 6), cornerRadius: 2)
        leftConnector.fillColor = cactusColor
        leftConnector.strokeColor = .clear
        leftConnector.position = CGPoint(x: -8, y: 20)
        cactus.addChild(leftConnector)

        // Right arm
        let rightArm = SKShapeNode(rectOf: CGSize(width: 8, height: 14), cornerRadius: 3)
        rightArm.fillColor = cactusColor
        rightArm.strokeColor = .clear
        rightArm.position = CGPoint(x: 12, y: 24)
        cactus.addChild(rightArm)

        let rightConnector = SKShapeNode(rectOf: CGSize(width: 8, height: 6), cornerRadius: 2)
        rightConnector.fillColor = cactusColor
        rightConnector.strokeColor = .clear
        rightConnector.position = CGPoint(x: 8, y: 18)
        cactus.addChild(rightConnector)

        return cactus
    }

    // MARK: - Obstacle

    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode {
        let container = SKNode()
        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2

        let stoneColors: [SKColor] = [
            SKColor(red: 0.75, green: 0.6, blue: 0.4, alpha: 1),
            SKColor(red: 0.7, green: 0.55, blue: 0.35, alpha: 1),
            SKColor(red: 0.8, green: 0.65, blue: 0.45, alpha: 1),
        ]
        let stoneStroke = SKColor(red: 0.5, green: 0.4, blue: 0.25, alpha: 1)

        // Top sandstone column
        let topHeight = sceneHeight - gapTop
        if topHeight > 0 {
            // Layered segments
            let segmentCount = 3
            let segmentHeight = topHeight / CGFloat(segmentCount)
            for s in 0..<segmentCount {
                let widthVariation = CGFloat(s % 2 == 0 ? 0 : -4)
                let seg = SKShapeNode(rectOf: CGSize(width: pipeWidth + widthVariation, height: segmentHeight))
                seg.fillColor = stoneColors[s % stoneColors.count]
                seg.strokeColor = stoneStroke
                seg.lineWidth = 1
                seg.position = CGPoint(x: 0, y: gapTop + CGFloat(s) * segmentHeight + segmentHeight / 2)
                seg.name = "obstacle"
                if s == 0 {
                    // Single physics body covering full column
                    let bodyNode = SKNode()
                    bodyNode.position = CGPoint(x: 0, y: gapTop + topHeight / 2)
                    bodyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topHeight))
                    bodyNode.physicsBody?.isDynamic = false
                    bodyNode.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
                    bodyNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
                    bodyNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                    container.addChild(bodyNode)
                }
                container.addChild(seg)
            }

            // Cracks
            for _ in 0..<3 {
                let crackY = CGFloat.random(in: gapTop + 10...max(gapTop + 11, sceneHeight - 10))
                let crack = SKShapeNode(rectOf: CGSize(width: pipeWidth * 0.6, height: 1))
                crack.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.5)
                crack.strokeColor = .clear
                crack.position = CGPoint(x: CGFloat.random(in: -5...5), y: crackY)
                container.addChild(crack)
            }

            // Cap: flat mesa top
            let capSize = CGSize(width: pipeWidth + 12, height: 12)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 1)
            topCap.fillColor = SKColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 1)
            topCap.strokeColor = stoneStroke
            topCap.lineWidth = 1
            topCap.position = CGPoint(x: 0, y: gapTop + 6)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topCap)
        }

        // Bottom sandstone column
        if gapBottom > 0 {
            let segmentCount = 3
            let segmentHeight = gapBottom / CGFloat(segmentCount)
            for s in 0..<segmentCount {
                let widthVariation = CGFloat(s % 2 == 0 ? 0 : -4)
                let seg = SKShapeNode(rectOf: CGSize(width: pipeWidth + widthVariation, height: segmentHeight))
                seg.fillColor = stoneColors[s % stoneColors.count]
                seg.strokeColor = stoneStroke
                seg.lineWidth = 1
                seg.position = CGPoint(x: 0, y: CGFloat(s) * segmentHeight + segmentHeight / 2)
                seg.name = "obstacle"
                if s == 0 {
                    let bodyNode = SKNode()
                    bodyNode.position = CGPoint(x: 0, y: gapBottom / 2)
                    bodyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
                    bodyNode.physicsBody?.isDynamic = false
                    bodyNode.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
                    bodyNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
                    bodyNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                    container.addChild(bodyNode)
                }
                container.addChild(seg)
            }

            // Cracks
            for _ in 0..<2 {
                let crackY = CGFloat.random(in: 10...max(11, gapBottom - 10))
                let crack = SKShapeNode(rectOf: CGSize(width: pipeWidth * 0.5, height: 1))
                crack.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.5)
                crack.strokeColor = .clear
                crack.position = CGPoint(x: CGFloat.random(in: -5...5), y: crackY)
                container.addChild(crack)
            }

            // Cap: flat mesa top
            let capSize = CGSize(width: pipeWidth + 12, height: 12)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 1)
            bottomCap.fillColor = SKColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 1)
            bottomCap.strokeColor = stoneStroke
            bottomCap.lineWidth = 1
            bottomCap.position = CGPoint(x: 0, y: gapBottom - 6)
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

        // Light sand
        let ground = SKShapeNode(rectOf: size)
        ground.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.55, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(ground)

        // Sand ripple lines
        for k in 0..<3 {
            let rippleY = size.height * 0.3 + CGFloat(k) * 8
            let ripple = SKShapeNode(rectOf: CGSize(width: size.width * 0.6, height: 1))
            ripple.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.45, alpha: 0.5)
            ripple.strokeColor = .clear
            ripple.position = CGPoint(x: size.width / 2 + CGFloat.random(in: -20...20), y: rippleY)
            container.addChild(ripple)
        }

        // Small rocks
        for _ in 0..<3 {
            let x = CGFloat.random(in: 10...(size.width - 10))
            let rock = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            rock.fillColor = SKColor(red: 0.5, green: 0.45, blue: 0.35, alpha: 0.6)
            rock.strokeColor = .clear
            rock.position = CGPoint(x: x, y: size.height * 0.6)
            container.addChild(rock)
        }

        return container
    }

    // MARK: - Preview

    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = .systemYellow

        // Mini dune
        let dune = SKShapeNode(ellipseOf: CGSize(width: 50, height: 18))
        dune.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.5, alpha: 1)
        dune.strokeColor = .clear
        dune.position = CGPoint(x: size.width * 0.35, y: 18)
        scene.addChild(dune)

        // Mini cactus
        let trunk = SKShapeNode(rectOf: CGSize(width: 4, height: 16), cornerRadius: 1)
        trunk.fillColor = SKColor(red: 0.15, green: 0.45, blue: 0.1, alpha: 0.8)
        trunk.strokeColor = .clear
        trunk.position = CGPoint(x: size.width * 0.2, y: 22)
        scene.addChild(trunk)

        let arm = SKShapeNode(rectOf: CGSize(width: 3, height: 8), cornerRadius: 1)
        arm.fillColor = SKColor(red: 0.15, green: 0.45, blue: 0.1, alpha: 0.8)
        arm.strokeColor = .clear
        arm.position = CGPoint(x: size.width * 0.2 + 5, y: 24)
        scene.addChild(arm)

        // Mini sandstone column
        let column = SKShapeNode(rectOf: CGSize(width: 10, height: 30))
        column.fillColor = SKColor(red: 0.75, green: 0.6, blue: 0.4, alpha: 1)
        column.strokeColor = .clear
        column.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        scene.addChild(column)

        // Mini ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        ground.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.55, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 5)
        scene.addChild(ground)

        return scene
    }
}
