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

/// Renders an EnvironmentPreviewScene off-screen and captures frames as images.
/// Avoids SpriteView constraint loop issues on macOS by using a hidden SKView.
class EnvironmentPreviewRenderer: ObservableObject {
    #if os(iOS)
    @Published var currentFrame: UIImage?
    #else
    @Published var currentFrame: NSImage?
    #endif

    private let skView: SKView
    private let scene: EnvironmentPreviewScene
    private var displayLink: Timer?

    init(environment: GameEnvironment) {
        let size = CGSize(width: 170, height: 100)
        self.skView = SKView(frame: CGRect(origin: .zero, size: size))
        skView.allowsTransparency = false

        let scene = EnvironmentPreviewScene(environment: environment, size: size)
        scene.scaleMode = .resizeFill
        self.scene = scene

        skView.presentScene(scene)
    }

    func start() {
        scene.isPaused = false
        displayLink = Timer.scheduledTimer(withTimeInterval: 1.0 / 15.0, repeats: true) { [weak self] _ in
            self?.captureFrame()
        }
    }

    func stop() {
        scene.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
    }

    private func captureFrame() {
        guard let texture = skView.texture(from: scene) else { return }
        let cgImage = texture.cgImage()

        #if os(iOS)
        currentFrame = UIImage(cgImage: cgImage)
        #else
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        currentFrame = NSImage(cgImage: cgImage, size: size)
        #endif
    }

    deinit {
        stop()
    }
}

struct LiveEnvironmentPreview: View {
    let environment: GameEnvironment
    @StateObject private var renderer: EnvironmentPreviewRenderer

    init(environment: GameEnvironment) {
        self.environment = environment
        _renderer = StateObject(wrappedValue: EnvironmentPreviewRenderer(environment: environment))
    }

    var body: some View {
        Group {
            #if os(iOS)
            if let frame = renderer.currentFrame {
                Image(uiImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle().fill(Color(environment.backgroundColor))
            }
            #else
            if let frame = renderer.currentFrame {
                Image(nsImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle().fill(Color(nsColor: environment.backgroundColor))
            }
            #endif
        }
        .frame(width: 170, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            renderer.start()
        }
        .onDisappear {
            renderer.stop()
        }
    }
}
