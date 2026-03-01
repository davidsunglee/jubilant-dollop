import AudioKit

protocol EnvironmentMusicProvider {
    func start(engine: AudioEngine, mixer: Mixer)
    func stop()
}
