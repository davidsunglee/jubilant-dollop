import AudioKit
import AudioKitEX
import AVFoundation
import SoundpipeAudioKit

class SFXGenerator {
    static let shared = SFXGenerator()

    private let engine = AudioEngine()
    private let mixer = Mixer()

    private init() {
        engine.output = mixer
        do {
            try engine.start()
        } catch {
            print("SFXGenerator start error: \(error)")
        }
    }

    // MARK: - Flap Sound (soft whoosh)
    // White noise burst with bandpass sweep, ~50ms

    func playFlap() {
        let noise = WhiteNoise()
        let filter = BandPassButterworthFilter(noise)
        filter.centerFrequency = 3000
        filter.bandwidth = 1000
        let fader = Fader(filter)
        fader.gain = 0.4

        mixer.addInput(fader)
        noise.start()

        // Sweep filter down and fade out
        let steps = 10
        let duration = 0.06 // 60ms total
        for i in 0...steps {
            let fraction = Double(i) / Double(steps)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * fraction) {
                filter.centerFrequency = AUValue(3000 - 2500 * fraction)
                fader.gain = Float(0.4 * (1.0 - fraction))
                if i == steps {
                    noise.stop()
                    self.mixer.removeInput(fader)
                }
            }
        }
    }

    // MARK: - Score Sound (ascending chime)
    // Two-note major third, sine wave

    func playScore() {
        let osc1 = Oscillator(waveform: Table(.sine))
        osc1.frequency = 880 // A5
        osc1.amplitude = 0.3
        let osc2 = Oscillator(waveform: Table(.sine))
        osc2.frequency = 1109 // C#6 (major third above A5)
        osc2.amplitude = 0.3

        let noteMixer = Mixer([osc1, osc2])
        let fader = Fader(noteMixer)
        mixer.addInput(fader)

        // Play first note
        osc1.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            // Add second note
            osc2.start()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Fade out
            let fadeSteps = 8
            for i in 0...fadeSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02 * Double(i)) {
                    fader.gain = Float(1.0 - Double(i) / Double(fadeSteps))
                    if i == fadeSteps {
                        osc1.stop()
                        osc2.stop()
                        self.mixer.removeInput(fader)
                    }
                }
            }
        }
    }

    // MARK: - Collision Sound (low thud)
    // Low-frequency noise burst with descending pitch

    func playCollision() {
        let osc = Oscillator(waveform: Table(.sine))
        osc.frequency = 150
        osc.amplitude = 0.5
        let noise = WhiteNoise()
        noise.amplitude = 0.2
        let filter = LowPassButterworthFilter(noise)
        filter.cutoffFrequency = 500

        let collisionMixer = Mixer([osc, filter])
        let fader = Fader(collisionMixer)
        mixer.addInput(fader)

        osc.start()
        noise.start()

        // Descend pitch and fade
        let steps = 15
        let duration = 0.25
        for i in 0...steps {
            let fraction = Double(i) / Double(steps)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * fraction) {
                osc.frequency = AUValue(150 - 100 * fraction)
                fader.gain = Float(1.0 - fraction * 0.8)
                if i == steps {
                    osc.stop()
                    noise.stop()
                    self.mixer.removeInput(fader)
                }
            }
        }
    }
}
