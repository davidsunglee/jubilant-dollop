import SpriteKit

protocol EnvironmentRenderer {
    /// Build background layers (gradient sky, scenery, animated elements).
    /// Returns nodes that should be added to the scene.
    /// Also sets up ParallaxBackground layers.
    func buildBackground(scene: SKScene, size: CGSize, parallax: ParallaxBackground)

    /// Build a pair of obstacles (top + bottom) with gap.
    /// Returns an SKNode with physics bodies configured.
    func buildObstacle(sceneHeight: CGFloat, gapCenterY: CGFloat, gapHeight: CGFloat, pipeWidth: CGFloat) -> SKNode

    /// Build the ground strip node for one parallax tile.
    func buildGroundTile(size: CGSize) -> SKNode

    /// Render a preview image for the environment selection screen.
    func renderPreview(size: CGSize, environment: GameEnvironment) -> SKScene
}
