import AudioKit
import Foundation
import SoundpipeAudioKit

class UnderwaterMusicProvider: EnvironmentMusicProvider {
    private var padOsc1: Oscillator?
    private var padOsc2: Oscillator?   // Slightly detuned for chorus effect
    private var arpOsc: Oscillator?
    private var trackMixer: Mixer?
    private var padTimer: Timer?
    private var arpTimer: Timer?

    // Dreamy/floaty at ~90 BPM
    private let beatDuration = 60.0 / 90.0

    // Eb major / C minor notes for watery feel - sustained pads
    private let padNotes: [AUValue] = [
        311.13, 311.13, 311.13, 311.13, // Eb4
        369.99, 369.99, 369.99, 369.99, // F#4/Gb4
        349.23, 349.23, 349.23, 349.23, // F4
        293.66, 293.66, 293.66, 293.66  // D4
    ]

    // Slow arpeggios with gaps
    private let arpNotes: [AUValue] = [
        622.25, 0, 0, 739.99, 0, 0, 830.61, 0,
        0, 0, 622.25, 0, 0, 0, 0, 0,
        587.33, 0, 0, 698.46, 0, 0, 830.61, 0,
        0, 0, 0, 0, 587.33, 0, 0, 0
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        padOsc1 = Oscillator(waveform: Table(.sine))
        padOsc1?.amplitude = 0.15

        // Second oscillator detuned by ~3 Hz for chorus effect
        padOsc2 = Oscillator(waveform: Table(.sine))
        padOsc2?.amplitude = 0.12

        arpOsc = Oscillator(waveform: Table(.sine))
        arpOsc?.amplitude = 0

        let tm = Mixer([padOsc1!, padOsc2!, arpOsc!])
        tm.volume = 0.3
        trackMixer = tm
        mixer.addInput(tm)

        padOsc1?.start()
        padOsc2?.start()
        arpOsc?.start()

        // Pad: very slow note changes
        var padIdx = 0
        padTimer = Timer.scheduledTimer(withTimeInterval: beatDuration * 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.padNotes[padIdx % self.padNotes.count]
            self.padOsc1?.frequency = note
            self.padOsc2?.frequency = note + 3.0 // Slight detune for chorus
            self.padOsc1?.amplitude = 0.15
            self.padOsc2?.amplitude = 0.12
            padIdx += 1
        }

        // Slow arpeggios
        var arpIdx = 0
        arpTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.arpNotes[arpIdx % self.arpNotes.count]
            if note > 0 {
                self.arpOsc?.frequency = note
                self.arpOsc?.amplitude = 0.12
                // Very gentle decay
                DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration * 0.6) {
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
        arpTimer?.invalidate()
        arpTimer = nil
        padOsc1?.stop()
        padOsc2?.stop()
        arpOsc?.stop()
        trackMixer = nil
    }
}
