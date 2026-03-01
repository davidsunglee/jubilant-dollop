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
