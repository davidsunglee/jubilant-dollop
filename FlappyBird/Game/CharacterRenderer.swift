import SpriteKit

class CharacterRenderer {
    static func createNode(for character: GameCharacter) -> SKNode {
        let container = SKNode()
        container.name = "characterVisual"

        let size = character.physicsBodySize

        // Base shape
        let shape: SKShapeNode
        switch character {
        case .avian:
            shape = SKShapeNode(circleOfRadius: character.circleRadius)
            shape.fillColor = character.color
            shape.strokeColor = .orange
            shape.lineWidth = 2

        case .wingedPig:
            shape = SKShapeNode(rectOf: size, cornerRadius: 8)
            shape.fillColor = character.color
            shape.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
            shape.lineWidth = 2

        case .flyingSquirrel:
            shape = SKShapeNode(rectOf: size, cornerRadius: 6)
            shape.fillColor = character.color
            shape.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
            shape.lineWidth = 2

        case .pegasus:
            shape = SKShapeNode(rectOf: size, cornerRadius: 4)
            shape.fillColor = character.color
            shape.strokeColor = .lightGray
            shape.lineWidth = 2

        case .wingedTurtle:
            shape = SKShapeNode(circleOfRadius: character.circleRadius)
            shape.fillColor = character.color
            shape.strokeColor = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1)
            shape.lineWidth = 2

        case .bat:
            shape = SKShapeNode(circleOfRadius: character.circleRadius)
            shape.fillColor = character.color
            shape.strokeColor = .black
            shape.lineWidth = 2
        }

        container.addChild(shape)

        // Add SF Symbol overlay
        let symbolNode = createSymbolNode(named: character.sfSymbolName, size: size)
        if let symbolNode = symbolNode {
            container.addChild(symbolNode)
        }

        // Add wing decoration
        let wing = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.4, height: size.height * 0.3))
        wing.fillColor = character.color.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -size.width * 0.3, y: size.height * 0.15)
        wing.name = "wing"
        container.addChild(wing)

        // Add wing flap animation
        let flapUp = SKAction.moveBy(x: 0, y: 6, duration: 0.15)
        let flapDown = SKAction.moveBy(x: 0, y: -6, duration: 0.15)
        let flap = SKAction.sequence([flapUp, flapDown])
        wing.run(SKAction.repeatForever(flap))

        return container
    }

    private static func createSymbolNode(named symbolName: String, size: CGSize) -> SKSpriteNode? {
        let symbolSize = CGSize(width: size.width * 0.6, height: size.height * 0.6)

        #if os(iOS)
        let config = UIImage.SymbolConfiguration(pointSize: symbolSize.height, weight: .regular)
        guard let uiImage = UIImage(systemName: symbolName, withConfiguration: config) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: symbolSize.width, height: symbolSize.height))
        let renderedImage = renderer.image { context in
            uiImage.withTintColor(.white, renderingMode: .alwaysTemplate)
                .draw(in: CGRect(origin: .zero, size: symbolSize))
        }
        let texture = SKTexture(image: renderedImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else { return nil }
        let config = NSImage.SymbolConfiguration(pointSize: symbolSize.height, weight: .regular)
        let configuredImage = nsImage.withSymbolConfiguration(config) ?? nsImage
        let texture = SKTexture(image: configuredImage)
        #endif

        let sprite = SKSpriteNode(texture: texture, size: symbolSize)
        sprite.colorBlendFactor = 1.0
        sprite.color = .white
        return sprite
    }
}
