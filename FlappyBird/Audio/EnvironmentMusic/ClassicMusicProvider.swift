import AudioKit
import Foundation
import SoundpipeAudioKit

class ClassicMusicProvider: EnvironmentMusicProvider {
    private var melodyOsc: Oscillator?
    private var bassOsc: Oscillator?
    private var trackMixer: Mixer?
    private var melodyTimer: Timer?
    private var bassTimer: Timer?

    private let beatDuration = 60.0 / 140.0

    // Cheerful C major melody
    private let melody: [AUValue] = [
        523.25, 587.33, 659.25, 783.99, 659.25, 587.33, 523.25, 0,
        659.25, 783.99, 880.00, 783.99, 659.25, 523.25, 587.33, 0,
        523.25, 659.25, 783.99, 1046.50, 880.00, 783.99, 659.25, 587.33,
        523.25, 587.33, 659.25, 523.25, 0, 523.25, 587.33, 659.25
    ]

    private let bass: [AUValue] = [
        130.81, 0, 130.81, 0, 174.61, 0, 174.61, 0,
        146.83, 0, 146.83, 0, 164.81, 0, 164.81, 0,
        130.81, 0, 174.61, 0, 196.00, 0, 164.81, 0,
        130.81, 0, 130.81, 0, 196.00, 0, 130.81, 0
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        melodyOsc = Oscillator(waveform: Table(.square))
        melodyOsc?.amplitude = 0.25
        bassOsc = Oscillator(waveform: Table(.triangle))
        bassOsc?.amplitude = 0.35

        let tm = Mixer([melodyOsc!, bassOsc!])
        tm.volume = 0.3
        trackMixer = tm
        mixer.addInput(tm)

        melodyOsc?.start()
        bassOsc?.start()

        var melodyIdx = 0
        melodyTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.melody[melodyIdx % self.melody.count]
            if note > 0 {
                self.melodyOsc?.frequency = note
                self.melodyOsc?.amplitude = 0.25
            } else {
                self.melodyOsc?.amplitude = 0
            }
            melodyIdx += 1
        }

        var bassIdx = 0
        bassTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.bass[bassIdx % self.bass.count]
            if note > 0 {
                self.bassOsc?.frequency = note
                self.bassOsc?.amplitude = 0.35
            } else {
                self.bassOsc?.amplitude = 0
            }
            bassIdx += 1
        }
    }

    func stop() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        bassTimer?.invalidate()
        bassTimer = nil
        melodyOsc?.stop()
        bassOsc?.stop()
        trackMixer = nil
    }
}
