# Audio Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Polish three audio elements — softer flap sound, gentler score chime, and more dynamic arctic music.

**Architecture:** All audio is programmatically synthesized using AudioKit oscillators, filters, and faders. SFX are one-shot sounds in `SFXGenerator`. Environment music uses long-running timers in provider classes. No audio files — all changes are parameter tuning and synthesis code.

**Tech Stack:** Swift, AudioKit 5.6+, SoundpipeAudioKit

---

### Task 1: Update Flap Sound — Soft Puff of Air

**Files:**
- Modify: `FlappyBird/Audio/SFXGenerator.swift:24-49` (`playFlap()`)

**Step 1: Update flap synthesis parameters**

Replace the entire `playFlap()` method body with softer parameters:

```swift
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
```

Key differences from original:
- Center frequency: 3000 → 1200 (less harsh)
- Bandwidth: 1000 → 1500 (broader, breathier)
- Sweep range: 3000-500 → 1200-400 (gentler)
- Amplitude: 0.4 → 0.25 (softer)
- Duration: 60ms → 90ms (slower puff)
- Steps: 10 → 12 (smoother decay)

**Step 2: Build and test**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5`

If no `.xcodeproj`, use: `xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Audio/SFXGenerator.swift
git commit -m "feat(audio): soften flap sound to gentle puff of air

Lower bandpass frequency, widen bandwidth, reduce amplitude, and
extend duration for a fluffier, less harsh wing flap effect."
```

---

### Task 2: Update Score Sound — Gentle Bell Chime

**Files:**
- Modify: `FlappyBird/Audio/SFXGenerator.swift:54-86` (`playScore()`)

**Step 1: Update score synthesis parameters**

Replace the entire `playScore()` method body with warmer, quieter parameters:

```swift
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
```

Key differences from original:
- Frequencies: 880/1109 → 523/659 (octave lower, warmer)
- Amplitude: 0.15 → 0.08 (quieter)
- Fade-in: instant → 20ms ramp (gentler attack)
- Decay start: 200ms → 250ms (notes ring slightly longer)
- Fade duration: ~160ms → ~350ms (longer tail)
- Fade steps: 8 → 12 (smoother)

**Step 2: Build and test**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Audio/SFXGenerator.swift
git commit -m "feat(audio): make score chime warmer and quieter

Lower frequencies to C5/E5, reduce amplitude, add gentle fade-in,
and extend decay for a more dulcet bell-like sound."
```

---

### Task 3: Rewrite Arctic Music — Brisk & Sparkling

**Files:**
- Modify: `FlappyBird/Audio/EnvironmentMusic/ArcticMusicProvider.swift` (full rewrite)

**Step 1: Rewrite ArcticMusicProvider**

Replace the entire file contents:

```swift
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
```

Key differences from original:
- BPM: 105 → 120
- Melody: Sparse C6-C7 with mostly rests → continuous arpeggiated C5-G6 pentatonic
- Melody timer: every beat → every half-beat (eighth notes)
- New bass oscillator: triangle wave on beats 1 & 3, quick 200ms decay pulse
- Pad: every 4 beats → every 2 beats, with shimmer modulation
- Bell amplitude: 0.18 → 0.20

**Step 2: Build and test**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Audio/EnvironmentMusic/ArcticMusicProvider.swift
git commit -m "feat(audio): make arctic music brisk and sparkling

Increase tempo to 120 BPM, add continuous arpeggiated melody, rhythmic
bass pulse on downbeats, faster pad changes with shimmer modulation."
```
