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

    // MARK: - Flap Sound (soft puff of air)
    // White noise burst with bandpass sweep, ~90ms

    func playFlap() {
        let noise = WhiteNoise()
        let filter = BandPassButterworthFilter(noise)
        filter.centerFrequency = 1200
        filter.bandwidth = 1500
        let fader = Fader(filter)
        fader.gain = 0.25

        mixer.addInput(fader)
        noise.start()

        // Gentler sweep down and fade out
        let steps = 12
        let duration = 0.09 // 90ms total
        for i in 0...steps {
            let fraction = Double(i) / Double(steps)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * fraction) {
                filter.centerFrequency = AUValue(1200 - 800 * fraction)
                fader.gain = Float(0.25 * (1.0 - fraction))
                if i == steps {
                    noise.stop()
                    self.mixer.removeInput(fader)
                }
            }
        }
    }

    // MARK: - Score Sound (gentle bell chime)
    // Two-note major third, sine wave, warm and quiet

    func playScore() {
        let osc1 = Oscillator(waveform: Table(.sine))
        osc1.frequency = 523 // C5 (was A5 880)
        osc1.amplitude = 0
        let osc2 = Oscillator(waveform: Table(.sine))
        osc2.frequency = 659 // E5 (was C#6 1109)
        osc2.amplitude = 0

        let noteMixer = Mixer([osc1, osc2])
        let fader = Fader(noteMixer)
        mixer.addInput(fader)

        // Play first note with gentle fade-in
        osc1.start()
        let fadeInSteps = 4
        for i in 0...fadeInSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(i)) {
                osc1.amplitude = AUValue(0.08 * Double(i) / Double(fadeInSteps))
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            // Add second note with gentle fade-in
            osc2.start()
            for i in 0...fadeInSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(i)) {
                    osc2.amplitude = AUValue(0.08 * Double(i) / Double(fadeInSteps))
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Longer, smoother fade out
            let fadeSteps = 12
            let fadeInterval = 0.35 / Double(fadeSteps)
            for i in 0...fadeSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + fadeInterval * Double(i)) {
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
