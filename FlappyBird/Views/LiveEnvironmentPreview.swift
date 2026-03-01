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
        guard isPaused == false else { return }
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 15.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        parallax?.update(deltaTime: min(deltaTime, 0.1))
    }
}

/// Holds the scene instance so it isn't recreated on every SwiftUI body evaluation.
class EnvironmentPreviewSceneHolder: ObservableObject {
    let scene: EnvironmentPreviewScene

    init(environment: GameEnvironment) {
        let scene = EnvironmentPreviewScene(
            environment: environment,
            size: CGSize(width: 170, height: 100)
        )
        scene.scaleMode = .resizeFill
        self.scene = scene
    }
}

struct LiveEnvironmentPreview: View {
    let environment: GameEnvironment
    @StateObject private var holder: EnvironmentPreviewSceneHolder

    init(environment: GameEnvironment) {
        self.environment = environment
        _holder = StateObject(wrappedValue: EnvironmentPreviewSceneHolder(environment: environment))
    }

    var body: some View {
        SpriteView(scene: holder.scene, options: [.allowsTransparency])
            .frame(width: 170, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onDisappear {
                holder.scene.isPaused = true
            }
            .onAppear {
                holder.scene.isPaused = false
            }
    }
}
