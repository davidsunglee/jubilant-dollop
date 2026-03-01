import SpriteKit

class ArcticEnvironmentRenderer: EnvironmentRenderer {

    // MARK: - Background

    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
        scene.backgroundColor = SKColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1)

        // Far layer: snowy mountain silhouettes (0.3x)
        var farNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            let mountains: [(x: CGFloat, baseWidth: CGFloat, peakHeight: CGFloat)] = [
                (size.width * 0.15, 120, 130),
                (size.width * 0.45, 160, 170),
                (size.width * 0.75, 100, 110),
                (size.width * 0.95, 140, 145),
            ]
            for m in mountains {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: m.x - m.baseWidth / 2, y: 40))
                path.addLine(to: CGPoint(x: m.x, y: 40 + m.peakHeight))
                path.addLine(to: CGPoint(x: m.x + m.baseWidth / 2, y: 40))
                path.closeSubpath()

                let mountain = SKShapeNode(path: path)
                mountain.fillColor = SKColor(white: 0.95, alpha: 1)
                mountain.strokeColor = SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 1)
                mountain.lineWidth = 1
                container.addChild(mountain)
            }

            container.zPosition = -8
            scene.addChild(container)
            farNodes.append(container)
        }
        parallax.addLayer(nodes: farNodes, speedMultiplier: 0.3, width: size.width)

        // Mid layer: snow drifts (0.6x)
        var midNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            let driftPositions: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
                (size.width * 0.2, 80, 25),
                (size.width * 0.5, 100, 30),
                (size.width * 0.8, 70, 20),
            ]
            for d in driftPositions {
                let drift = SKShapeNode(ellipseOf: CGSize(width: d.w, height: d.h))
                drift.fillColor = SKColor(white: 1.0, alpha: 0.8)
                drift.strokeColor = .clear
                drift.position = CGPoint(x: d.x, y: 50 + d.h / 2)
                container.addChild(drift)
            }

            container.zPosition = -6
            scene.addChild(container)
            midNodes.append(container)
        }
        parallax.addLayer(nodes: midNodes, speedMultiplier: 0.6, width: size.width)

        // Animated: snowflakes
        for _ in 0..<7 {
            let snowflake = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
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
                x: CGFloat.random(in: -30...30),
                y: -(size.height + 20),
                duration: TimeInterval.random(in: 8...15)
            )
            let reset = SKAction.run {
                snowflake.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: size.height + 10
                )
            }
            snowflake.run(SKAction.repeatForever(SKAction.sequence([fall, reset])))
        }
    }

    // MARK: - Obstacle

    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode {
        let container = SKNode()
        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2
        let iceColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1)
        let iceStroke = SKColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1)

        // Top ice pillar
        let topHeight = sceneHeight - gapTop
        if topHeight > 0 {
            let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: topHeight), cornerRadius: 3)
            topPipe.fillColor = iceColor
            topPipe.strokeColor = iceStroke
            topPipe.lineWidth = 2
            topPipe.position = CGPoint(x: 0, y: gapTop + topHeight / 2)
            topPipe.name = "obstacle"
            topPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topHeight))
            topPipe.physicsBody?.isDynamic = false
            topPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topPipe)

            // Frost shapes along edges
            for _ in 0..<4 {
                let frost = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 3...6)), cornerRadius: 2)
                frost.fillColor = SKColor(white: 1.0, alpha: 0.6)
                frost.strokeColor = .clear
                frost.position = CGPoint(
                    x: CGFloat.random(in: -pipeWidth / 3...pipeWidth / 3),
                    y: CGFloat.random(in: gapTop + 10...max(gapTop + 11, sceneHeight - 10))
                )
                container.addChild(frost)
            }

            // Icicles hanging from bottom edge of top pillar
            for k in 0..<3 {
                let icicleH = CGFloat.random(in: 8...16)
                let icicleX = CGFloat(k - 1) * pipeWidth * 0.3
                let iciclePath = CGMutablePath()
                iciclePath.move(to: CGPoint(x: icicleX - 3, y: gapTop))
                iciclePath.addLine(to: CGPoint(x: icicleX, y: gapTop - icicleH))
                iciclePath.addLine(to: CGPoint(x: icicleX + 3, y: gapTop))
                iciclePath.closeSubpath()
                let icicle = SKShapeNode(path: iciclePath)
                icicle.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.9)
                icicle.strokeColor = .clear
                container.addChild(icicle)
            }

            // Cap: snow drift
            let capSize = CGSize(width: pipeWidth + 10, height: 16)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 8)
            topCap.fillColor = .white
            topCap.strokeColor = iceStroke
            topCap.lineWidth = 1
            topCap.position = CGPoint(x: 0, y: gapTop + 8)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topCap)
        }

        // Bottom ice pillar
        if gapBottom > 0 {
            let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: gapBottom), cornerRadius: 3)
            bottomPipe.fillColor = iceColor
            bottomPipe.strokeColor = iceStroke
            bottomPipe.lineWidth = 2
            bottomPipe.position = CGPoint(x: 0, y: gapBottom / 2)
            bottomPipe.name = "obstacle"
            bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
            bottomPipe.physicsBody?.isDynamic = false
            bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomPipe)

            // Frost shapes
            for _ in 0..<3 {
                let frost = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 3...6)), cornerRadius: 2)
                frost.fillColor = SKColor(white: 1.0, alpha: 0.6)
                frost.strokeColor = .clear
                frost.position = CGPoint(
                    x: CGFloat.random(in: -pipeWidth / 3...pipeWidth / 3),
                    y: CGFloat.random(in: 10...max(11, gapBottom - 10))
                )
                container.addChild(frost)
            }

            // Icicles growing upward from top edge of bottom pillar
            for k in 0..<3 {
                let icicleH = CGFloat.random(in: 6...12)
                let icicleX = CGFloat(k - 1) * pipeWidth * 0.3
                let iciclePath = CGMutablePath()
                iciclePath.move(to: CGPoint(x: icicleX - 3, y: gapBottom))
                iciclePath.addLine(to: CGPoint(x: icicleX, y: gapBottom + icicleH))
                iciclePath.addLine(to: CGPoint(x: icicleX + 3, y: gapBottom))
                iciclePath.closeSubpath()
                let icicle = SKShapeNode(path: iciclePath)
                icicle.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.9)
                icicle.strokeColor = .clear
                container.addChild(icicle)
            }

            // Cap: snow drift
            let capSize = CGSize(width: pipeWidth + 10, height: 16)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 8)
            bottomCap.fillColor = .white
            bottomCap.strokeColor = iceStroke
            bottomCap.lineWidth = 1
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

        // Ice layer beneath
        let ice = SKShapeNode(rectOf: size)
        ice.fillColor = SKColor(red: 0.8, green: 0.88, blue: 0.95, alpha: 1)
        ice.strokeColor = .clear
        ice.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(ice)

        // White snow on top
        let snow = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.6))
        snow.fillColor = .white
        snow.strokeColor = .clear
        snow.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        container.addChild(snow)

        // Snow drift bumps
        for _ in 0..<5 {
            let x = CGFloat.random(in: 10...(size.width - 10))
            let bump = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 10...20), height: CGFloat.random(in: 5...8)))
            bump.fillColor = .white
            bump.strokeColor = .clear
            bump.position = CGPoint(x: x, y: size.height + 2)
            container.addChild(bump)
        }

        return container
    }

    // MARK: - Preview

    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = SKColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1)

        // Mini mountain
        let mtnPath = CGMutablePath()
        mtnPath.move(to: CGPoint(x: size.width * 0.3, y: 12))
        mtnPath.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.7))
        mtnPath.addLine(to: CGPoint(x: size.width * 0.7, y: 12))
        mtnPath.closeSubpath()
        let mountain = SKShapeNode(path: mtnPath)
        mountain.fillColor = SKColor(white: 0.95, alpha: 1)
        mountain.strokeColor = SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 1)
        mountain.lineWidth = 1
        scene.addChild(mountain)

        // Mini snowflakes
        for i in 0..<3 {
            let dot = SKShapeNode(circleOfRadius: 1.5)
            dot.fillColor = .white
            dot.strokeColor = .clear
            dot.position = CGPoint(x: size.width * CGFloat(i + 1) / 4, y: size.height * 0.8)
            scene.addChild(dot)
        }

        // Mini ice pillar
        let pillar = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 2)
        pillar.fillColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1)
        pillar.strokeColor = .clear
        pillar.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        scene.addChild(pillar)

        // Mini ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        ground.fillColor = .white
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 5)
        scene.addChild(ground)

        return scene
    }
}
