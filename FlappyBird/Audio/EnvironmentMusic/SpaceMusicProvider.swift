import AudioKit
import Foundation
import SoundpipeAudioKit

class SpaceMusicProvider: EnvironmentMusicProvider {
    private var padOsc: Oscillator?
    private var subBassOsc: Oscillator?
    private var arpOsc: Oscillator?
    private var trackMixer: Mixer?
    private var padTimer: Timer?
    private var bassTimer: Timer?
    private var arpTimer: Timer?

    // Atmospheric synth at ~100 BPM
    private let beatDuration = 60.0 / 100.0

    // A minor pentatonic for spacey feel
    private let padNotes: [AUValue] = [
        220.00, 220.00, 220.00, 220.00, // A3 sustained
        261.63, 261.63, 261.63, 261.63, // C4
        196.00, 196.00, 196.00, 196.00, // G3
        174.61, 174.61, 174.61, 174.61  // F3
    ]

    // Deep sub-bass pulses
    private let bassNotes: [AUValue] = [
        55.00, 0, 0, 0, 55.00, 0, 0, 0,
        65.41, 0, 0, 0, 65.41, 0, 0, 0,
        49.00, 0, 0, 0, 49.00, 0, 0, 0,
        43.65, 0, 0, 0, 43.65, 0, 0, 0
    ]

    // Sparse arpeggios with long gaps
    private let arpNotes: [AUValue] = [
        440.00, 0, 523.25, 0, 659.25, 0, 0, 0,
        0, 0, 587.33, 0, 440.00, 0, 0, 0,
        392.00, 0, 523.25, 0, 0, 0, 659.25, 0,
        0, 0, 0, 0, 440.00, 0, 0, 0
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        padOsc = Oscillator(waveform: Table(.sine))
        padOsc?.amplitude = 0.15

        subBassOsc = Oscillator(waveform: Table(.sine))
        subBassOsc?.amplitude = 0

        arpOsc = Oscillator(waveform: Table(.sine))
        arpOsc?.amplitude = 0

        let tm = Mixer([padOsc!, subBassOsc!, arpOsc!])
        tm.volume = 0.3
        trackMixer = tm
        mixer.addInput(tm)

        padOsc?.start()
        subBassOsc?.start()
        arpOsc?.start()

        // Pad: slow frequency changes with shimmer
        var padIdx = 0
        padTimer = Timer.scheduledTimer(withTimeInterval: beatDuration * 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.padNotes[padIdx % self.padNotes.count]
            self.padOsc?.frequency = note
            self.padOsc?.amplitude = 0.15
            padIdx += 1

            // Slow shimmer via slight frequency modulation
            let baseFreq = note
            let steps = 8
            for i in 0..<steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 2 * Double(i) / Double(steps)) {
                    let wobble = sin(Double(i) * .pi / 4.0) * 2.0
                    self.padOsc?.frequency = baseFreq + AUValue(wobble)
                }
            }
        }

        // Sub-bass pulses
        var bassIdx = 0
        bassTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.bassNotes[bassIdx % self.bassNotes.count]
            if note > 0 {
                self.subBassOsc?.frequency = note
                self.subBassOsc?.amplitude = 0.3
                // Fade out over beat
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.5) {
                    self.subBassOsc?.amplitude = 0.1
                }
            } else {
                self.subBassOsc?.amplitude = 0
            }
            bassIdx += 1
        }

        // Sparse arpeggios
        var arpIdx = 0
        arpTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.arpNotes[arpIdx % self.arpNotes.count]
            if note > 0 {
                self.arpOsc?.frequency = note
                self.arpOsc?.amplitude = 0.15
                // Long decay
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.7) {
                    self.arpOsc?.amplitude = 0.03
                }
            } else {
                self.arpOsc?.amplitude = 0
            }
            arpIdx += 1
        }
    }

    func stop() {
        padTimer?.invalidate()
        padTimer = nil
        bassTimer?.invalidate()
        bassTimer = nil
        arpTimer?.invalidate()
        arpTimer = nil
        padOsc?.stop()
        subBassOsc?.stop()
        arpOsc?.stop()
        trackMixer = nil
    }
}
