import AudioKit
import SoundpipeAudioKit

protocol EnvironmentMusicProvider {
    func start(engine: AudioEngine, mixer: Mixer)
    func stop()
}
