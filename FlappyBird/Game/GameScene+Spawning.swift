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

        let pipe = PipeNode(
            sceneHeight: size.height,
            gapCenterY: randomGapY,
            gapHeight: gapHeight,
            pipeWidth: pipeWidth,
            color: router.config.environment.obstacleColor
        )

        pipe.position = CGPoint(x: size.width + pipeWidth, y: 0)
        pipe.zPosition = 1
        addChild(pipe)

        // Move pipe across screen and remove when off-screen
        let distance = size.width + pipeWidth * 2
        let duration = TimeInterval(distance / pipeSpeed)
        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()
        pipe.run(SKAction.sequence([moveAction, removeAction]))
    }
}
