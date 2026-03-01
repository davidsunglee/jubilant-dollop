import SwiftUI
import SpriteKit

class EnvironmentPreviewScene: SKScene {
    private let environment: GameEnvironment
    private var parallax: ParallaxBackground?
    private var lastUpdateTime: TimeInterval = 0

    init(environment: GameEnvironment, size: CGSize) {
        self.environment = environment
        super.init(size: size)
        backgroundColor = environment.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        view.preferredFramesPerSecond = 15

        let parallax = ParallaxBackground(baseSpeed: 20)
        let renderer = environment.renderer
        renderer.buildPreviewBackground(scene: self, size: size, parallax: parallax)

        // Add ground as 1.0x parallax layer
        let groundHeight: CGFloat = 8
        let groundSize = CGSize(width: size.width, height: groundHeight)
        var groundNodes: [SKNode] = []
        for i in 0..<2 {
            let tile = renderer.buildGroundTile(size: groundSize)
            tile.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
            tile.zPosition = -2
            addChild(tile)
            groundNodes.append(tile)
        }
        parallax.addLayer(nodes: groundNodes, speedMultiplier: 1.0, width: size.width)

        self.parallax = parallax
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 15.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        parallax?.update(deltaTime: min(deltaTime, 0.1))
    }
}

struct LiveEnvironmentPreview: View {
    let environment: GameEnvironment

    private var scene: EnvironmentPreviewScene {
        let scene = EnvironmentPreviewScene(
            environment: environment,
            size: CGSize(width: 170, height: 100)
        )
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: 170, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
