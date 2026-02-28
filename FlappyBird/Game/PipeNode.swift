import SpriteKit

class PipeNode: SKNode {
    let gapCenterY: CGFloat
    let gapHeight: CGFloat

    init(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat, color: SKColor) {
        self.gapCenterY = gapCenterY
        self.gapHeight = gapHeight
        super.init()

        name = "pipePair"

        let gapTop = gapCenterY + gapHeight / 2
        let gapBottom = gapCenterY - gapHeight / 2

        // Top pipe
        let topPipeHeight = sceneHeight - gapTop
        if topPipeHeight > 0 {
            let topPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: topPipeHeight), cornerRadius: 4)
            topPipe.fillColor = color
            topPipe.strokeColor = color.withAlphaComponent(0.8)
            topPipe.lineWidth = 2
            topPipe.position = CGPoint(x: 0, y: gapTop + topPipeHeight / 2)
            topPipe.name = "obstacle"

            topPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: topPipeHeight))
            topPipe.physicsBody?.isDynamic = false
            topPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player

            addChild(topPipe)

            // Top pipe cap
            let capSize = CGSize(width: pipeWidth + 10, height: 20)
            let topCap = SKShapeNode(rectOf: capSize, cornerRadius: 4)
            topCap.fillColor = color
            topCap.strokeColor = color.withAlphaComponent(0.6)
            topCap.lineWidth = 2
            topCap.position = CGPoint(x: 0, y: gapTop + 10)
            topCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            topCap.physicsBody?.isDynamic = false
            topCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            topCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            topCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            addChild(topCap)
        }

        // Bottom pipe
        if gapBottom > 0 {
            let bottomPipe = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: gapBottom), cornerRadius: 4)
            bottomPipe.fillColor = color
            bottomPipe.strokeColor = color.withAlphaComponent(0.8)
            bottomPipe.lineWidth = 2
            bottomPipe.position = CGPoint(x: 0, y: gapBottom / 2)
            bottomPipe.name = "obstacle"

            bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeWidth, height: gapBottom))
            bottomPipe.physicsBody?.isDynamic = false
            bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player

            addChild(bottomPipe)

            // Bottom pipe cap
            let capSize = CGSize(width: pipeWidth + 10, height: 20)
            let bottomCap = SKShapeNode(rectOf: capSize, cornerRadius: 4)
            bottomCap.fillColor = color
            bottomCap.strokeColor = color.withAlphaComponent(0.6)
            bottomCap.lineWidth = 2
            bottomCap.position = CGPoint(x: 0, y: gapBottom - 10)
            bottomCap.physicsBody = SKPhysicsBody(rectangleOf: capSize)
            bottomCap.physicsBody?.isDynamic = false
            bottomCap.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            bottomCap.physicsBody?.contactTestBitMask = PhysicsCategory.player
            bottomCap.physicsBody?.collisionBitMask = PhysicsCategory.player
            addChild(bottomCap)
        }

        // Score zone (invisible, in the gap)
        let scoreZone = SKNode()
        scoreZone.position = CGPoint(x: 0, y: gapCenterY)
        scoreZone.name = "scoreZone"

        scoreZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: gapHeight))
        scoreZone.physicsBody?.isDynamic = false
        scoreZone.physicsBody?.categoryBitMask = PhysicsCategory.scoreZone
        scoreZone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        scoreZone.physicsBody?.collisionBitMask = PhysicsCategory.none  // No physical collision

        addChild(scoreZone)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
