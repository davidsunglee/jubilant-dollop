import SpriteKit

class CharacterRenderer {
    static func createNode(for character: GameCharacter) -> SKNode {
        let container = SKNode()
        container.name = "characterVisual"

        switch character {
        case .avian:          buildAvian(in: container)
        case .wingedPig:      buildWingedPig(in: container)
        case .flyingSquirrel: buildFlyingSquirrel(in: container)
        case .pegasus:        buildPegasus(in: container)
        case .wingedTurtle:   buildWingedTurtle(in: container)
        case .bat:            buildBat(in: container)
        }

        return container
    }

    // MARK: - Avian
    private static func buildAvian(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 15)
        body.fillColor = .yellow
        body.strokeColor = .orange
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 12, height: 9))
        wing.fillColor = SKColor.yellow.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -9, y: 5)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 6, duration: 0.15)
    }

    // MARK: - Winged Pig
    private static func buildWingedPig(in container: SKNode) {
        let body = SKShapeNode(rectOf: CGSize(width: 36, height: 28), cornerRadius: 8)
        body.fillColor = .systemPink
        body.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 8))
        wing.fillColor = SKColor.systemPink.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -11, y: 4)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 4, duration: 0.12)
    }

    // MARK: - Flying Squirrel
    private static func buildFlyingSquirrel(in container: SKNode) {
        let body = SKShapeNode(rectOf: CGSize(width: 40, height: 20), cornerRadius: 6)
        body.fillColor = .brown
        body.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 16, height: 6))
        wing.fillColor = SKColor.brown.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -12, y: 3)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 3, duration: 0.25)
    }

    // MARK: - Pegasus
    private static func buildPegasus(in container: SKNode) {
        let body = SKShapeNode(rectOf: CGSize(width: 38, height: 32), cornerRadius: 4)
        body.fillColor = .white
        body.strokeColor = .lightGray
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 15, height: 10))
        wing.fillColor = SKColor.white.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -11, y: 5)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 10, duration: 0.2)
    }

    // MARK: - Winged Turtle
    private static func buildWingedTurtle(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 17)
        body.fillColor = .green
        body.strokeColor = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 9))
        wing.fillColor = SKColor.green.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -10, y: 3)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 5, duration: 0.08)
    }

    // MARK: - Bat
    private static func buildBat(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 12)
        body.fillColor = .darkGray
        body.strokeColor = .black
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 10, height: 7))
        wing.fillColor = SKColor.darkGray.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -7, y: 4)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 8, duration: 0.18)
    }

    // MARK: - Wing Animation Helper
    private static func addWingAnimation(to wing: SKShapeNode, range: CGFloat, duration: TimeInterval) {
        let flapUp = SKAction.moveBy(x: 0, y: range, duration: duration)
        let flapDown = SKAction.moveBy(x: 0, y: -range, duration: duration)
        let flap = SKAction.sequence([flapUp, flapDown])
        wing.run(SKAction.repeatForever(flap))
    }
}
