import AudioKit
import AVFoundation
import SoundpipeAudioKit

class MusicEngine {
    static let shared = MusicEngine()

    private let engine = AudioEngine()
    private let mixer = Mixer()

    // Active oscillators for current track
    private var activeOscillators: [Oscillator] = []
    private var activeMixer: Mixer?

    private(set) var isRunning = false

    private init() {
        engine.output = mixer
    }

    func start() {
        guard !isRunning else { return }
        do {
            try engine.start()
            isRunning = true
        } catch {
            print("MusicEngine start error: \(error)")
        }
    }

    func stop() {
        stopAllOscillators()
        engine.stop()
        isRunning = false
    }

    /// Play a set of oscillator nodes through the mixer
    func play(oscillators: [Oscillator], throughMixer trackMixer: Mixer, volume: Float = 0.3) {
        start()
        activeMixer = trackMixer
        activeOscillators = oscillators
        trackMixer.volume = volume
        mixer.addInput(trackMixer)
        for osc in oscillators {
            osc.start()
        }
    }

    /// Stop all currently playing oscillators
    func stopAllOscillators() {
        for osc in activeOscillators {
            osc.stop()
        }
        if let trackMixer = activeMixer {
            mixer.removeInput(trackMixer)
        }
        activeOscillators = []
        activeMixer = nil
    }

    /// Crossfade: fade out current, fade in new over duration
    func crossfade(to oscillators: [Oscillator], throughMixer newMixer: Mixer, duration: TimeInterval = 1.0, volume: Float = 0.3) {
        let oldMixer = activeMixer
        let oldOscillators = activeOscillators

        // Start new track
        play(oscillators: oscillators, throughMixer: newMixer, volume: 0)

        // Fade
        let steps = 20
        let stepDuration = duration / Double(steps)
        for i in 0...steps {
            let fraction = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                newMixer.volume = volume * fraction
                oldMixer?.volume = volume * (1.0 - fraction)
                if i == steps {
                    // Clean up old
                    for osc in oldOscillators {
                        osc.stop()
                    }
                    if let oldMixer = oldMixer {
                        self.mixer.removeInput(oldMixer)
                    }
                }
            }
        }
    }
}
