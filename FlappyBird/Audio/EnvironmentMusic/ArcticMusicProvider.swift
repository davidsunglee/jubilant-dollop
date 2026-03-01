import AudioKit

class ArcticMusicProvider: EnvironmentMusicProvider {
    private var bellOsc: Oscillator?
    private var padOsc: Oscillator?
    private var trackMixer: Mixer?
    private var melodyTimer: Timer?
    private var padTimer: Timer?

    // Crystalline/sparse at ~105 BPM
    private let beatDuration = 60.0 / 105.0

    // High bell-like melody (C6-C7 range) - very sparse with long silences
    private let melody: [AUValue] = [
        1046.50, 0, 0, 0, 1174.66, 0, 0, 0,
        0, 0, 1318.51, 0, 0, 0, 0, 0,
        1396.91, 0, 0, 0, 0, 0, 1174.66, 0,
        0, 0, 0, 0, 1046.50, 0, 0, 0
    ]

    // Gentle low pad - F major / D minor
    private let padNotes: [AUValue] = [
        174.61, 174.61, 174.61, 174.61, // F3
        146.83, 146.83, 146.83, 146.83, // D3
        164.81, 164.81, 164.81, 164.81, // E3
        130.81, 130.81, 130.81, 130.81  // C3
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        bellOsc = Oscillator(waveform: Table(.sine))
        bellOsc?.amplitude = 0

        padOsc = Oscillator(waveform: Table(.sine))
        padOsc?.amplitude = 0.1

        let tm = Mixer([bellOsc!, padOsc!])
        tm.volume = 0.3
        trackMixer = tm
        mixer.addInput(tm)

        bellOsc?.start()
        padOsc?.start()

        // Sparse bell melody
        var melodyIdx = 0
        melodyTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.melody[melodyIdx % self.melody.count]
            if note > 0 {
                self.bellOsc?.frequency = note
                self.bellOsc?.amplitude = 0.18
                // Bell-like decay
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.3) {
                    self.bellOsc?.amplitude = 0.08
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.7) {
                    self.bellOsc?.amplitude = 0.02
                }
            } else {
                self.bellOsc?.amplitude = 0
            }
            melodyIdx += 1
        }

        // Slow pad changes
        var padIdx = 0
        padTimer = Timer.scheduledTimer(withTimeInterval: beatDuration * 4, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.padNotes[padIdx % self.padNotes.count]
            self.padOsc?.frequency = note
            self.padOsc?.amplitude = 0.1
            padIdx += 1
        }
    }

    func stop() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        padTimer?.invalidate()
        padTimer = nil
        bellOsc?.stop()
        padOsc?.stop()
        trackMixer = nil
    }
}
