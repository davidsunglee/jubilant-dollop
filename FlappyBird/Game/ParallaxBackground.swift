import SpriteKit

class ParallaxBackground {
    private var backgroundNodes: [SKSpriteNode] = []
    private let scrollSpeed: CGFloat
    private weak var parentNode: SKNode?

    init(color: SKColor, size: CGSize, scrollSpeed: CGFloat = 100, parent: SKNode) {
        self.scrollSpeed = scrollSpeed
        self.parentNode = parent

        // Create two identical background nodes for infinite scrolling
        for i in 0..<2 {
            let bg = SKSpriteNode(color: color, size: size)
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
            bg.zPosition = -10
            bg.name = "parallaxBg\(i)"
            parent.addChild(bg)
            backgroundNodes.append(bg)
        }
    }

    func update(deltaTime: TimeInterval) {
        guard let firstNode = backgroundNodes.first else { return }
        let width = firstNode.size.width

        for node in backgroundNodes {
            node.position.x -= scrollSpeed * CGFloat(deltaTime)

            // When a node's right edge scrolls off screen, reposition behind the other
            if node.position.x + width <= 0 {
                // Find the rightmost node
                let maxX = backgroundNodes.map { $0.position.x }.max() ?? 0
                node.position.x = maxX + width
            }
        }
    }

    func stop() {
        // No-op; the update loop simply won't call update anymore
    }

    func removeFromParent() {
        for node in backgroundNodes {
            node.removeFromParent()
        }
        backgroundNodes.removeAll()
    }
}
