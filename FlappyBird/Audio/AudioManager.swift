import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private init() {}

    // MARK: - Menu Music

    func playMenuMusic(forState state: GameState) {
        switch state {
        case .title:
            EnvironmentMusicManager.shared.stop()
            MenuMusicProvider.shared.setLayer(1)
        case .characterSelection:
            MenuMusicProvider.shared.setLayer(2)
        case .environmentSelection:
            MenuMusicProvider.shared.setLayer(3)
        case .playing, .gameOver:
            break
        }
    }

    // MARK: - Gameplay Music

    func playEnvironmentMusic(for environment: GameEnvironment) {
        MenuMusicProvider.shared.stopPlaying()
        EnvironmentMusicManager.shared.play(environment: environment)
    }

    func stopMusic() {
        MenuMusicProvider.shared.stopPlaying()
        EnvironmentMusicManager.shared.stop()
    }

    // MARK: - Sound Effects

    func playFlapSound() {
        SFXGenerator.shared.playFlap()
    }

    func playScoreSound() {
        SFXGenerator.shared.playScore()
    }

    func playCollisionSound() {
        SFXGenerator.shared.playCollision()
    }
}
