import SpriteKit

class SpaceEnvironmentRenderer: EnvironmentRenderer {

    // MARK: - Background

    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground) {
        scene.backgroundColor = .black

        // Static star field (fixed, no parallax)
        for _ in 0..<35 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
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

            // Subtle twinkle
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.3...0.6), duration: TimeInterval.random(in: 1.5...3.0)),
                SKAction.fadeAlpha(to: 1.0, duration: TimeInterval.random(in: 1.5...3.0)),
            ])
            star.run(SKAction.repeatForever(twinkle))
        }

        // Far layer: distant nebula smudges (0.3x)
        var farNodes: [SKNode] = []
        for i in 0..<2 {
            let container = SKNode()
            container.position = CGPoint(x: CGFloat(i) * size.width, y: 0)

            let nebulaConfigs: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: SKColor)] = [
                (size.width * 0.25, size.height * 0.7, 100, 60,
                 SKColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.2)),
                (size.width * 0.6, size.height * 0.4, 80, 50,
                 SKColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 0.18)),
                (size.width * 0.8, size.height * 0.8, 70, 45,
                 SKColor(red: 0.6, green: 0.15, blue: 0.4, alpha: 0.15)),
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

        // Animated: shooting star
        let shootingStar = SKShapeNode(ellipseOf: CGSize(width: 8, height: 2))
        shootingStar.fillColor = .white
        shootingStar.strokeColor = .clear
        shootingStar.position = CGPoint(x: -20, y: size.height * 0.8)
        shootingStar.zPosition = -5
        shootingStar.alpha = 0
        scene.addChild(shootingStar)

        let waitAction = SKAction.wait(forDuration: TimeInterval.random(in: 3...8))
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let streak = SKAction.moveBy(x: size.width + 50, y: -size.height * 0.4, duration: 0.5)
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.1)
        let reset = SKAction.run {
            shootingStar.position = CGPoint(
                x: CGFloat.random(in: -20...size.width * 0.3),
                y: CGFloat.random(in: size.height * 0.6...size.height)
            )
        }
        let nextWait = SKAction.wait(forDuration: TimeInterval.random(in: 3...8))
        shootingStar.run(SKAction.repeatForever(SKAction.sequence([waitAction, appear, streak, fade, reset, nextWait])))
    }

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

    // MARK: - Obstacle

    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode {
        let container = SKNode()
        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2
        let barrierColor = SKColor.purple
        let barrierStroke = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1)

        // Top energy barrier
        let topHeight = sceneHeight - gapTop
        if topHeight > 0 {
            let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: topHeight), cornerRadius: 2)
            topPipe.fillColor = barrierColor
            topPipe.strokeColor = barrierStroke
            topPipe.lineWidth = 2
            topPipe.position = CGPoint(x: 0, y: gapTop + topHeight / 2)
            topPipe.name = "obstacle"
            topPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topHeight))
            topPipe.physicsBody?.isDynamic = false
            topPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topPipe)

            // Inner glow
            let innerGlow = SKShapeNode(rectOf: CGSize(width: pipeWidth - 8, height: topHeight - 8), cornerRadius: 2)
            innerGlow.fillColor = SKColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 0.4)
            innerGlow.strokeColor = .clear
            innerGlow.position = CGPoint(x: 0, y: gapTop + topHeight / 2)
            container.addChild(innerGlow)

            // Electrical sparks
            for _ in 0..<3 {
                let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
                spark.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 0.9)
                spark.strokeColor = .clear
                spark.position = CGPoint(
                    x: CGFloat.random(in: -pipeWidth / 2...pipeWidth / 2),
                    y: CGFloat.random(in: gapTop + 5...max(gapTop + 6, sceneHeight - 5))
                )
                container.addChild(spark)

                let flicker = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1),
                    SKAction.wait(forDuration: TimeInterval.random(in: 0.3...1.0)),
                ])
                spark.run(SKAction.repeatForever(flicker))
            }

            // Cap: pulsing glow
            let capSize = CGSize(width: pipeWidth + 10, height: 16)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 4)
            topCap.fillColor = barrierColor
            topCap.strokeColor = barrierStroke
            topCap.lineWidth = 2
            topCap.position = CGPoint(x: 0, y: gapTop + 8)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(topCap)

            // Glow overlay on cap
            let capGlow = SKShapeNode(rectOf: CGSize(width: pipeWidth + 14, height: 20), cornerRadius: 6)
            capGlow.fillColor = SKColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 0.3)
            capGlow.strokeColor = .clear
            capGlow.position = CGPoint(x: 0, y: gapTop + 8)
            container.addChild(capGlow)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.1, duration: 0.8),
                SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            ])
            capGlow.run(SKAction.repeatForever(pulse))
        }

        // Bottom energy barrier
        if gapBottom > 0 {
            let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: gapBottom), cornerRadius: 2)
            bottomPipe.fillColor = barrierColor
            bottomPipe.strokeColor = barrierStroke
            bottomPipe.lineWidth = 2
            bottomPipe.position = CGPoint(x: 0, y: gapBottom / 2)
            bottomPipe.name = "obstacle"
            bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
            bottomPipe.physicsBody?.isDynamic = false
            bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomPipe)

            // Inner glow
            let innerGlow = SKShapeNode(rectOf: CGSize(width: pipeWidth - 8, height: gapBottom - 8), cornerRadius: 2)
            innerGlow.fillColor = SKColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 0.4)
            innerGlow.strokeColor = .clear
            innerGlow.position = CGPoint(x: 0, y: gapBottom / 2)
            container.addChild(innerGlow)

            // Electrical sparks
            for _ in 0..<3 {
                let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
                spark.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 0.9)
                spark.strokeColor = .clear
                spark.position = CGPoint(
                    x: CGFloat.random(in: -pipeWidth / 2...pipeWidth / 2),
                    y: CGFloat.random(in: 5...max(6, gapBottom - 5))
                )
                container.addChild(spark)

                let flicker = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1),
                    SKAction.wait(forDuration: TimeInterval.random(in: 0.3...1.0)),
                ])
                spark.run(SKAction.repeatForever(flicker))
            }

            // Cap: pulsing glow
            let capSize = CGSize(width: pipeWidth + 10, height: 16)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 4)
            bottomCap.fillColor = barrierColor
            bottomCap.strokeColor = barrierStroke
            bottomCap.lineWidth = 2
            bottomCap.position = CGPoint(x: 0, y: gapBottom - 8)
            bottomCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            bottomCap.physicsBody?.isDynamic = false
            bottomCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            container.addChild(bottomCap)

            let capGlow = SKShapeNode(rectOf: CGSize(width: pipeWidth + 14, height: 20), cornerRadius: 6)
            capGlow.fillColor = SKColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 0.3)
            capGlow.strokeColor = .clear
            capGlow.position = CGPoint(x: 0, y: gapBottom - 8)
            container.addChild(capGlow)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.1, duration: 0.8),
                SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            ])
            capGlow.run(SKAction.repeatForever(pulse))
        }

        return container
    }

    // MARK: - Ground

    func buildGroundTile(size: CGSize) -> SKNode {
        let container = SKNode()

        // Dark purple metallic base
        let ground = SKShapeNode(rectOf: size)
        ground.fillColor = SKColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.addChild(ground)

        // Neon edge line on top
        let neonLine = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
        neonLine.fillColor = SKColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 1)
        neonLine.strokeColor = .clear
        neonLine.position = CGPoint(x: size.width / 2, y: size.height - 1)
        container.addChild(neonLine)

        // Rivets
        let rivetCount = Int(size.width / 25)
        for k in 0..<rivetCount {
            let rivet = SKShapeNode(circleOfRadius: 1.5)
            rivet.fillColor = SKColor(white: 0.5, alpha: 0.7)
            rivet.strokeColor = .clear
            rivet.position = CGPoint(x: CGFloat(k) * 25 + 12, y: size.height * 0.4)
            container.addChild(rivet)
        }

        return container
    }

    // MARK: - Preview

    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = .black

        // Mini stars
        for _ in 0..<8 {
            let star = SKShapeNode(circleOfRadius: 1)
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.3...size.height)
            )
            scene.addChild(star)
        }

        // Mini nebula
        let nebula = SKShapeNode(ellipseOf: CGSize(width: 25, height: 15))
        nebula.fillColor = SKColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.25)
        nebula.strokeColor = .clear
        nebula.position = CGPoint(x: size.width * 0.3, y: size.height * 0.7)
        scene.addChild(nebula)

        // Mini purple barrier
        let barrier = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 2)
        barrier.fillColor = .purple
        barrier.strokeColor = .clear
        barrier.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        scene.addChild(barrier)

        // Mini ground with neon line
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 8))
        ground.fillColor = SKColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 4)
        scene.addChild(ground)

        let neon = SKShapeNode(rectOf: CGSize(width: size.width, height: 1))
        neon.fillColor = SKColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 1)
        neon.strokeColor = .clear
        neon.position = CGPoint(x: size.width / 2, y: 8)
        scene.addChild(neon)

        return scene
    }
}
