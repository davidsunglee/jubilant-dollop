import SpriteKit

struct ParallaxLayer {
    let nodes: [SKNode]
    let speedMultiplier: CGFloat
    let width: CGFloat
}

class ParallaxBackground {
    private var layers: [ParallaxLayer] = []
    private let baseSpeed: CGFloat

    init(baseSpeed: CGFloat = 150) {
        self.baseSpeed = baseSpeed
    }

    func addLayer(nodes: [SKNode], speedMultiplier: CGFloat, width: CGFloat) {
        let layer = ParallaxLayer(nodes: nodes, speedMultiplier: speedMultiplier, width: width)
        layers.append(layer)
    }

    func update(deltaTime: TimeInterval) {
        for layer in layers {
            let speed = baseSpeed * layer.speedMultiplier
            for node in layer.nodes {
                node.position.x -= speed * CGFloat(deltaTime)

                if node.position.x + layer.width <= 0 {
                    let maxX = layer.nodes.map { $0.position.x }.max() ?? 0
                    node.position.x = maxX + layer.width
                }
            }
        }
    }

    func removeFromParent() {
        for layer in layers {
            for node in layer.nodes {
                node.removeFromParent()
            }
        }
        layers.removeAll()
    }
}
