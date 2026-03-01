import SwiftUI
import SpriteKit

class CharacterPreviewScene: SKScene {
    private let character: GameCharacter
    private let isSelected: Bool
    private var characterNode: SKNode?

    init(character: GameCharacter, isSelected: Bool, size: CGSize) {
        self.character = character
        self.isSelected = isSelected
        super.init(size: size)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()

        let node = CharacterRenderer.createNode(for: character)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(node)
        characterNode = node

        let amplitude: CGFloat = isSelected ? 7 : 4
        let bobUp = SKAction.moveBy(x: 0, y: amplitude, duration: 0.375)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SKAction.moveBy(x: 0, y: -amplitude, duration: 0.375)
        bobDown.timingMode = .easeInEaseOut
        let bob = SKAction.sequence([bobUp, bobDown])
        node.run(SKAction.repeatForever(bob))
    }
}

struct LiveCharacterPreview: View {
    let character: GameCharacter
    let isSelected: Bool

    private var scene: CharacterPreviewScene {
        let scene = CharacterPreviewScene(
            character: character,
            isSelected: isSelected,
            size: CGSize(width: 60, height: 60)
        )
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: 60, height: 60)
    }
}
