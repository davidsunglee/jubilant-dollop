import SpriteKit

class PlayerNode: SKNode {
    let playerIndex: Int  // 1 or 2
    let character: GameCharacter
    var isAlive: Bool = true

    init(playerIndex: Int, character: GameCharacter) {
        self.playerIndex = playerIndex
        self.character = character
        super.init()

        name = "player\(playerIndex)"

        // Add character visual
        let visual = CharacterRenderer.createNode(for: character)
        addChild(visual)

        // Configure physics body
        if character.useCircleBody {
            physicsBody = SKPhysicsBody(circleOfRadius: character.circleRadius)
        } else {
            physicsBody = SKPhysicsBody(rectangleOf: character.physicsBodySize)
        }

        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.scoreZone | PhysicsCategory.boundary
        physicsBody?.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.boundary
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func jump(impulse: CGFloat = 300) {
        guard isAlive else { return }
        // Set velocity directly instead of applyImpulse so behavior is consistent
        // regardless of physics body mass (which varies by character size)
        physicsBody?.velocity = CGVector(dx: 0, dy: impulse)
    }

    func die() {
        isAlive = false
        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.boundary

        // Death visual: fade self and colorize child sprite nodes
        run(SKAction.fadeAlpha(to: 0.4, duration: 0.3))

        let colorize = SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.3)
        enumerateChildNodes(withName: "//.", using: { node, _ in
            if let sprite = node as? SKSpriteNode {
                sprite.run(colorize)
            }
        })

        // Stop wing animation
        if let wing = childNode(withName: ".//wing") {
            wing.removeAllActions()
        }
    }
}
