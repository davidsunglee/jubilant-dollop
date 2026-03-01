import AudioKit

class EnvironmentMusicManager {
    static let shared = EnvironmentMusicManager()

    private let engine = AudioEngine()
    private let mixer = Mixer()
    private var currentProvider: EnvironmentMusicProvider?

    private init() {
        engine.output = mixer
    }

    func play(environment: GameEnvironment) {
        stop()
        let provider = musicProvider(for: environment)
        currentProvider = provider
        do {
            try engine.start()
        } catch {
            print("EnvironmentMusicManager start error: \(error)")
            return
        }
        provider.start(engine: engine, mixer: mixer)
    }

    func stop() {
        currentProvider?.stop()
        currentProvider = nil
        engine.stop()
    }

    private func musicProvider(for environment: GameEnvironment) -> EnvironmentMusicProvider {
        switch environment {
        case .classic:    return ClassicMusicProvider()
        case .desert:     return DesertMusicProvider()
        case .space:      return SpaceMusicProvider()
        case .jungle:     return JungleMusicProvider()
        case .underwater: return UnderwaterMusicProvider()
        case .arctic:     return ArcticMusicProvider()
        }
    }
}
