import AudioKit
import Foundation
import SoundpipeAudioKit

class JungleMusicProvider: EnvironmentMusicProvider {
    private var leadOsc: Oscillator?
    private var bassOsc: Oscillator?
    private var kickNoise: WhiteNoise?
    private var hihatNoise: WhiteNoise?
    private var kickFilter: LowPassButterworthFilter?
    private var hihatFilter: HighPassButterworthFilter?
    private var trackMixer: Mixer?
    private var melodyTimer: Timer?
    private var bassTimer: Timer?
    private var percTimer: Timer?

    // Tribal/rhythmic at ~130 BPM
    private let beatDuration = 60.0 / 130.0

    // C pentatonic melody (C, D, E, G, A) - syncopated
    private let melody: [AUValue] = [
        523.25, 0, 587.33, 0, 659.25, 659.25, 0, 783.99,
        0, 880.00, 783.99, 0, 659.25, 0, 587.33, 523.25,
        0, 523.25, 0, 659.25, 783.99, 0, 880.00, 0,
        783.99, 659.25, 0, 523.25, 587.33, 0, 523.25, 0
    ]

    // Strong root bass notes
    private let bass: [AUValue] = [
        130.81, 0, 0, 130.81, 0, 0, 130.81, 0,
        146.83, 0, 0, 146.83, 0, 0, 146.83, 0,
        130.81, 0, 0, 130.81, 0, 0, 164.81, 0,
        146.83, 0, 0, 130.81, 0, 130.81, 0, 0
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        leadOsc = Oscillator(waveform: Table(.triangle))
        leadOsc?.amplitude = 0.25
        bassOsc = Oscillator(waveform: Table(.triangle))
        bassOsc?.amplitude = 0.4

        // Percussion
        kickNoise = WhiteNoise()
        kickNoise?.amplitude = 0
        hihatNoise = WhiteNoise()
        hihatNoise?.amplitude = 0
        kickFilter = LowPassButterworthFilter(kickNoise!)
        kickFilter?.cutoffFrequency = 250
        hihatFilter = HighPassButterworthFilter(hihatNoise!)
        hihatFilter?.cutoffFrequency = 7000

        let tm = Mixer([leadOsc!, bassOsc!, kickFilter!, hihatFilter!])
        tm.volume = 0.4
        trackMixer = tm
        mixer.addInput(tm)

        leadOsc?.start()
        bassOsc?.start()
        kickNoise?.start()
        hihatNoise?.start()

        var melodyIdx = 0
        melodyTimer = Timer.scheduledTimer(withTimeInterval: beatDuration / 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.melody[melodyIdx % self.melody.count]
            if note > 0 {
                self.leadOsc?.frequency = note
                self.leadOsc?.amplitude = 0.25
            } else {
                self.leadOsc?.amplitude = 0
            }
            melodyIdx += 1
        }

        var bassIdx = 0
        bassTimer = Timer.scheduledTimer(withTimeInterval: beatDuration / 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.bass[bassIdx % self.bass.count]
            if note > 0 {
                self.bassOsc?.frequency = note
                self.bassOsc?.amplitude = 0.4
            } else {
                self.bassOsc?.amplitude = 0
            }
            bassIdx += 1
        }

        // Heavy syncopated percussion
        var percBeat = 0
        percTimer = Timer.scheduledTimer(withTimeInterval: beatDuration / 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Hi-hat on every eighth note
            self.hihatNoise?.amplitude = 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.hihatNoise?.amplitude = 0
            }
            // Kick on syncopated pattern: 1, &2, 3, &4
            if percBeat % 8 == 0 || percBeat % 8 == 3 || percBeat % 8 == 4 || percBeat % 8 == 7 {
                self.kickNoise?.amplitude = 0.35
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    self.kickNoise?.amplitude = 0
                }
            }
            percBeat += 1
        }
    }

    func stop() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        bassTimer?.invalidate()
        bassTimer = nil
        percTimer?.invalidate()
        percTimer = nil
        leadOsc?.stop()
        bassOsc?.stop()
        kickNoise?.stop()
        hihatNoise?.stop()
        trackMixer = nil
    }
}
