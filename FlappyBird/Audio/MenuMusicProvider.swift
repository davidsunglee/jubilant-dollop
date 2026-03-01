import AudioKit
import AVFoundation
import Foundation
import SoundpipeAudioKit

class MenuMusicProvider {
    static let shared = MenuMusicProvider()

    private let engine = AudioEngine()
    private let masterMixer = Mixer()

    // Layer oscillators
    private var melodyOsc: Oscillator?
    private var bassOsc: Oscillator?
    private var harmonyOsc: Oscillator?
    private var arpOsc: Oscillator?

    // Layer mixers for volume control
    private var layer1Mixer: Mixer?
    private var layer2Mixer: Mixer?
    private var layer3Mixer: Mixer?

    // Sequencing
    private var melodyTimer: Timer?
    private var bassTimer: Timer?
    private var harmonyTimer: Timer?
    private var arpTimer: Timer?
    private var percTimer: Timer?

    private var currentLayer: Int = 0
    private var isPlaying = false

    // Percussion
    private var kickNoise: WhiteNoise?
    private var hihatNoise: WhiteNoise?
    private var kickFilter: LowPassButterworthFilter?
    private var hihatFilter: HighPassButterworthFilter?

    // Melody: C major, upbeat 4-bar loop at ~140 BPM
    // Beat duration = 60/140 ≈ 0.4286s
    private let beatDuration: Double = 60.0 / 140.0

    // C major scale notes (Hz)
    private let melodyNotes: [AUValue] = [
        523.25, 587.33, 659.25, 698.46, 783.99, 659.25, 698.46, 587.33, // Bar 1-2
        523.25, 783.99, 698.46, 659.25, 587.33, 523.25, 587.33, 659.25  // Bar 3-4
    ]

    private let bassNotes: [AUValue] = [
        130.81, 130.81, 174.61, 174.61, 146.83, 146.83, 164.81, 164.81, // C2, C2, F2, F2, D2, D2, E2, E2
        130.81, 130.81, 174.61, 174.61, 196.00, 196.00, 130.81, 130.81  // repeat pattern
    ]

    private let harmonyNotes: [AUValue] = [
        659.25, 698.46, 783.99, 880.00, 783.99, 698.46, 659.25, 587.33,
        659.25, 783.99, 880.00, 783.99, 698.46, 659.25, 587.33, 523.25
    ]

    private let arpNotes: [AUValue] = [
        523.25, 659.25, 783.99, 1046.50, 783.99, 659.25, 523.25, 659.25,
        587.33, 698.46, 880.00, 1174.66, 880.00, 698.46, 587.33, 698.46
    ]

    private init() {
        engine.output = masterMixer
    }

    // MARK: - Layer Control

    /// Set the active layer count (1 = title, 2 = character select, 3 = environment select)
    func setLayer(_ layer: Int) {
        let targetLayer = max(0, min(3, layer))
        if !isPlaying && targetLayer > 0 {
            startPlaying(layer: targetLayer)
        } else if targetLayer == 0 {
            stopPlaying()
        } else {
            transitionToLayer(targetLayer)
        }
    }

    private func startPlaying(layer: Int) {
        setupOscillators()
        do {
            try engine.start()
        } catch {
            print("MenuMusicProvider start error: \(error)")
            return
        }
        isPlaying = true
        currentLayer = 0
        transitionToLayer(layer)
    }

    private func setupOscillators() {
        // Layer 1: Melody (square wave) + Bass (triangle wave)
        melodyOsc = Oscillator(waveform: Table(.square))
        melodyOsc?.amplitude = 0
        bassOsc = Oscillator(waveform: Table(.triangle))
        bassOsc?.amplitude = 0
        let l1m = Mixer([melodyOsc!, bassOsc!])
        l1m.volume = 0.15
        layer1Mixer = l1m

        // Layer 2: Harmony (triangle) + Percussion (noise)
        harmonyOsc = Oscillator(waveform: Table(.triangle))
        harmonyOsc?.amplitude = 0
        kickNoise = WhiteNoise()
        kickNoise?.amplitude = 0
        hihatNoise = WhiteNoise()
        hihatNoise?.amplitude = 0
        kickFilter = LowPassButterworthFilter(kickNoise!)
        kickFilter?.cutoffFrequency = 200
        hihatFilter = HighPassButterworthFilter(hihatNoise!)
        hihatFilter?.cutoffFrequency = 8000
        let l2m = Mixer([harmonyOsc!, kickFilter!, hihatFilter!])
        l2m.volume = 0
        layer2Mixer = l2m

        // Layer 3: Arp (sine wave, bright)
        arpOsc = Oscillator(waveform: Table(.sine))
        arpOsc?.amplitude = 0
        let l3m = Mixer([arpOsc!])
        l3m.volume = 0
        layer3Mixer = l3m

        masterMixer.addInput(l1m)
        masterMixer.addInput(l2m)
        masterMixer.addInput(l3m)

        // Start all oscillators (they start silent)
        melodyOsc?.start()
        bassOsc?.start()
        harmonyOsc?.start()
        kickNoise?.start()
        hihatNoise?.start()
        arpOsc?.start()
    }

    private func transitionToLayer(_ targetLayer: Int) {
        guard targetLayer != currentLayer else { return }
        currentLayer = targetLayer

        // Start sequencing timers if not already running
        startSequencers()

        // Fade layers in/out over 0.5s
        let fadeDuration = 0.5
        let steps = 10
        for i in 0...steps {
            let fraction = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration * Double(i) / Double(steps)) { [weak self] in
                guard let self = self else { return }
                self.layer1Mixer?.volume = targetLayer >= 1 ? 0.15 * fraction : 0.15 * (1 - fraction)
                self.layer2Mixer?.volume = targetLayer >= 2 ? 0.12 * fraction : 0.12 * (1 - fraction)
                self.layer3Mixer?.volume = targetLayer >= 3 ? 0.09 * fraction : 0.09 * (1 - fraction)
            }
        }
    }

    private func startSequencers() {
        guard melodyTimer == nil else { return }

        var melodyIndex = 0
        var bassIndex = 0
        var harmonyIndex = 0
        var arpIndex = 0
        var beatCount = 0

        // Melody: plays every beat
        melodyTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.melodyOsc?.frequency = self.melodyNotes[melodyIndex % self.melodyNotes.count]
            self.melodyOsc?.amplitude = 0.3
            melodyIndex += 1

            // Trigger bass on every 2nd beat
            if melodyIndex % 2 == 0 {
                self.bassOsc?.frequency = self.bassNotes[bassIndex % self.bassNotes.count]
                self.bassOsc?.amplitude = 0.4
                bassIndex += 1
            }

            // Harmony follows melody at thirds
            self.harmonyOsc?.frequency = self.harmonyNotes[harmonyIndex % self.harmonyNotes.count]
            self.harmonyOsc?.amplitude = 0.2
            harmonyIndex += 1

            // Arp plays twice per beat
            beatCount += 1
        }

        // Arp: plays twice per beat (eighth notes)
        arpTimer = Timer.scheduledTimer(withTimeInterval: beatDuration / 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.arpOsc?.frequency = self.arpNotes[arpIndex % self.arpNotes.count]
            self.arpOsc?.amplitude = 0.2
            arpIndex += 1

            // Quick decay
            DispatchQueue.main.asyncAfter(deadline: .now() + self.beatDuration / 4) {
                self.arpOsc?.amplitude = 0.05
            }
        }

        // Percussion: kick on beats 1 & 3, hihat on every beat
        var percBeat = 0
        percTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Hi-hat on every beat
            self.hihatNoise?.amplitude = 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                self.hihatNoise?.amplitude = 0
            }
            // Kick on beats 1 and 3
            if percBeat % 4 == 0 || percBeat % 4 == 2 {
                self.kickNoise?.amplitude = 0.4
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.kickNoise?.amplitude = 0
                }
            }
            percBeat += 1
        }
    }

    func stopPlaying() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        bassTimer?.invalidate()
        bassTimer = nil
        harmonyTimer?.invalidate()
        harmonyTimer = nil
        arpTimer?.invalidate()
        arpTimer = nil
        percTimer?.invalidate()
        percTimer = nil

        melodyOsc?.stop()
        bassOsc?.stop()
        harmonyOsc?.stop()
        arpOsc?.stop()
        kickNoise?.stop()
        hihatNoise?.stop()

        if let l1 = layer1Mixer { masterMixer.removeInput(l1) }
        if let l2 = layer2Mixer { masterMixer.removeInput(l2) }
        if let l3 = layer3Mixer { masterMixer.removeInput(l3) }

        layer1Mixer = nil
        layer2Mixer = nil
        layer3Mixer = nil

        engine.stop()
        isPlaying = false
        currentLayer = 0
    }
}
