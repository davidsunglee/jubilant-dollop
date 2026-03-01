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
