import AudioKit
import Foundation
import SoundpipeAudioKit

class ArcticMusicProvider: EnvironmentMusicProvider {
    private var bellOsc: Oscillator?
    private var padOsc: Oscillator?
    private var bassOsc: Oscillator?
    private var trackMixer: Mixer?
    private var melodyTimer: Timer?
    private var padTimer: Timer?
    private var bassTimer: Timer?
    private var shimmerTimer: Timer?

    // Brisk tempo at 120 BPM
    private let beatDuration = 60.0 / 120.0

    // C major pentatonic in C5-G6 range — sparkling arpeggiated patterns
    private let melody: [AUValue] = [
        523.25, 587.33, 659.25, 783.99,   // C5, D5, E5, G5
        880.00, 783.99, 659.25, 587.33,   // A5, G5, E5, D5
        523.25, 659.25, 783.99, 1046.50,  // C5, E5, G5, C6
        1318.51, 1174.66, 1046.50, 783.99,// E6, D6, C6, G5
        880.00, 1046.50, 1174.66, 1318.51,// A5, C6, D6, E6
        1567.98, 1318.51, 1046.50, 880.00,// G6, E6, C6, A5
        783.99, 659.25, 523.25, 0,        // G5, E5, C5, rest
        659.25, 783.99, 880.00, 1046.50   // E5, G5, A5, C6
    ]

    // Pad notes — C major with more harmonic motion
    private let padNotes: [AUValue] = [
        130.81, 164.81, 174.61, 146.83,   // C3, E3, F3, D3
        130.81, 196.00, 164.81, 174.61    // C3, G3, E3, F3
    ]

    // Bass pulse notes — C3-G3 range
    private let bassNotes: [AUValue] = [
        130.81, 196.00, 164.81, 196.00,   // C3, G3, E3, G3
        130.81, 174.61, 146.83, 196.00    // C3, F3, D3, G3
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        bellOsc = Oscillator(waveform: Table(.sine))
        bellOsc?.amplitude = 0

        padOsc = Oscillator(waveform: Table(.sine))
        padOsc?.amplitude = 0.1

        bassOsc = Oscillator(waveform: Table(.triangle))
        bassOsc?.amplitude = 0

        let tm = Mixer([bellOsc!, padOsc!, bassOsc!])
        tm.volume = 0.4
        trackMixer = tm
        mixer.addInput(tm)

        bellOsc?.start()
        padOsc?.start()
        bassOsc?.start()

        // Arpeggiated bell melody — mostly continuous
        var melodyIdx = 0
        melodyTimer = Timer.scheduledTimer(withTimeInterval: beatDuration * 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.melody[melodyIdx % self.melody.count]
            if note > 0 {
                self.bellOsc?.frequency = note
                self.bellOsc?.amplitude = 0.20
                // Bell-like decay
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.2) {
                    self.bellOsc?.amplitude = 0.10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.4) {
                    self.bellOsc?.amplitude = 0.03
                }
            } else {
                self.bellOsc?.amplitude = 0
            }
            melodyIdx += 1
        }

        // Pad changes every 2 beats with shimmer
        var padIdx = 0
        padTimer = Timer.scheduledTimer(withTimeInterval: beatDuration * 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.padNotes[padIdx % self.padNotes.count]
            self.padOsc?.frequency = note
            self.padOsc?.amplitude = 0.1
            padIdx += 1
        }

        // Shimmer effect on pad — subtle frequency wobble
        shimmerTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let pad = self.padOsc else { return }
            let baseFreq = pad.frequency
            let wobble = AUValue(sin(Date().timeIntervalSinceReferenceDate * 6.0) * 1.5)
            pad.frequency = baseFreq + wobble
        }

        // Bass pulse on beats 1 and 3
        var bassIdx = 0
        var beatCount = 0
        bassTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let isDownbeat = beatCount % 2 == 0
            if isDownbeat {
                let note = self.bassNotes[bassIdx % self.bassNotes.count]
                self.bassOsc?.frequency = note
                self.bassOsc?.amplitude = 0.12
                // Quick decay for pulse feel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.bassOsc?.amplitude = 0.04
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.bassOsc?.amplitude = 0
                }
                bassIdx += 1
            }
            beatCount += 1
        }
    }

    func stop() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        padTimer?.invalidate()
        padTimer = nil
        bassTimer?.invalidate()
        bassTimer = nil
        shimmerTimer?.invalidate()
        shimmerTimer = nil
        bellOsc?.stop()
        padOsc?.stop()
        bassOsc?.stop()
        trackMixer = nil
    }
}
