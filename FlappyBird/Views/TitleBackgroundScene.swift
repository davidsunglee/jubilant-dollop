import SpriteKit

class TitleBackgroundScene: SKScene {
    private var parallax: ParallaxBackground?
    private var lastUpdateTime: TimeInterval = 0

    override init(size: CGSize) {
        super.init(size: size)
        let environment = GameEnvironment.allCases.randomElement()!
        backgroundColor = environment.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        view.preferredFramesPerSecond = 30

        let environment = GameEnvironment.allCases.randomElement()!
        backgroundColor = environment.backgroundColor

        let parallax = ParallaxBackground(baseSpeed: 20)
        let renderer = environment.renderer
        renderer.buildBackground(scene: self, size: size, parallax: parallax)

        let groundHeight: CGFloat = size.height * 0.08
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
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 30.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        parallax?.update(deltaTime: min(deltaTime, 0.1))
    }
}

class TitleBackgroundSceneHolder: ObservableObject {
    let scene: TitleBackgroundScene

    init() {
        let scene = TitleBackgroundScene(size: CGSize(width: 400, height: 800))
        scene.scaleMode = .resizeFill
        self.scene = scene
    }
}
