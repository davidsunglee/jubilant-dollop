import AudioKit
import Foundation
import SoundpipeAudioKit

class DesertMusicProvider: EnvironmentMusicProvider {
    private var leadOsc: Oscillator?
    private var bassOsc: Oscillator?
    private var leadFilter: BandPassButterworthFilter?
    private var trackMixer: Mixer?
    private var melodyTimer: Timer?
    private var bassTimer: Timer?

    // Western/frontier style at ~120 BPM
    private let beatDuration = 60.0 / 120.0

    // D mixolydian melody for western feel
    private let melody: [AUValue] = [
        293.66, 329.63, 369.99, 440.00, 369.99, 329.63, 293.66, 0,
        440.00, 493.88, 440.00, 369.99, 329.63, 293.66, 0, 293.66,
        329.63, 369.99, 440.00, 493.88, 440.00, 0, 369.99, 329.63,
        293.66, 329.63, 293.66, 0, 261.63, 293.66, 0, 329.63
    ]

    // Galloping bass pattern (long-short-short rhythm via note/rest)
    private let bass: [AUValue] = [
        146.83, 0, 146.83, 146.83, 0, 0, 164.81, 0,
        164.81, 164.81, 0, 0, 130.81, 0, 130.81, 130.81,
        0, 0, 146.83, 0, 146.83, 146.83, 0, 0,
        130.81, 0, 130.81, 130.81, 0, 0, 146.83, 0
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        leadOsc = Oscillator(waveform: Table(.square))
        leadOsc?.amplitude = 0.2
        // Bandpass filter for twangy quality
        leadFilter = BandPassButterworthFilter(leadOsc!)
        leadFilter?.centerFrequency = 1200
        leadFilter?.bandwidth = 800

        bassOsc = Oscillator(waveform: Table(.triangle))
        bassOsc?.amplitude = 0.35

        let tm = Mixer([leadFilter!, bassOsc!])
        tm.volume = 0.4
        trackMixer = tm
        mixer.addInput(tm)

        leadOsc?.start()
        bassOsc?.start()

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
        leadOsc?.stop()
        bassOsc?.stop()
        trackMixer = nil
    }
}
