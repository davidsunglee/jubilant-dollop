import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()
    private var bgmPlayer: AVAudioPlayer?

    private init() {}

    // MARK: - Background Music

    func playBGM() {
        guard let url = Bundle.main.url(forResource: "bgm", withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            // Skip placeholder stubs — looping a tiny file produces constant beeping
            guard player.duration > 1.0 else { return }
            player.numberOfLoops = -1
            player.volume = 0.3
            player.play()
            bgmPlayer = player
        } catch {
            print("BGM playback error: \(error)")
        }
    }

    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    // MARK: - Sound Effects (via SKAction for zero-latency)

    func playFlapSound(on scene: SKScene) {
        let action = SKAction.playSoundFileNamed("flap.wav", waitForCompletion: false)
        scene.run(action)
    }

    func playScoreSound(on scene: SKScene) {
        let action = SKAction.playSoundFileNamed("score.wav", waitForCompletion: false)
        scene.run(action)
    }

    func playCollisionSound(on scene: SKScene) {
        let action = SKAction.playSoundFileNamed("collision.wav", waitForCompletion: false)
        scene.run(action)
    }
}
