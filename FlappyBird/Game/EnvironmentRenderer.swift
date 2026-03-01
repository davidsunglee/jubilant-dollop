import SpriteKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

protocol EnvironmentRenderer {
    /// Build background layers (gradient sky, scenery, animated elements).
    /// Returns nodes that should be added to the scene.
    /// Also sets up ParallaxBackground layers.
    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)

    /// Build miniature background layers for card preview (170x100pt).
    /// Uses the same ParallaxBackground system but with card-scaled geometry.
    func buildPreviewBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)

    /// Build a pair of obstacles (top + bottom) with gap.
    /// Returns an SKNode with physics bodies configured.
    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode

    /// Build the ground strip node for one parallax tile.
    func buildGroundTile(size: CGSize) -> SKNode

    /// Render a preview image for the environment selection screen.
    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene
}

enum EnvironmentPreviewRenderer {
    private static var cache: [GameEnvironment: CharacterRenderer.PlatformImage] = [:]

    static func renderToImage(for environment: GameEnvironment, size: CGSize = CGSize(width: 160, height: 80)) -> CharacterRenderer.PlatformImage? {
        if let cached = cache[environment] { return cached }

        let scene = environment.renderer.renderPreview(size: size, environment: environment)
        let view = SKView(frame: CGRect(origin: .zero, size: size))
        guard let texture = view.texture(from: scene) else { return nil }

        #if os(iOS)
        let image = UIImage(cgImage: texture.cgImage())
        #elseif os(macOS)
        let cgImage = texture.cgImage()
        let image = NSImage(cgImage: cgImage, size: size)
        #endif

        cache[environment] = image
        return image
    }
}
