# Sound & Music Overhaul Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the WAV-file audio system with fully programmatic music and sound effects using AudioKit, adding dynamic menu music, environment-specific gameplay tracks, and synthesized SFX.

**Architecture:** A `MusicEngine` wraps AudioKit's engine and oscillators. `MenuMusicProvider` and per-environment `EnvironmentMusicProvider` implementations generate music. `SFXGenerator` synthesizes flap/score/collision sounds. The existing `AudioManager` singleton is updated to coordinate everything, triggered by `GameRouter` state changes.

**Tech Stack:** AudioKit (SPM), AVFoundation, SpriteKit

---

### Task 1: Add AudioKit SPM Dependency

**Files:**
- Modify: `project.yml` (add SPM package + target dependencies)

**Step 1: Add AudioKit package to project.yml**

Add the `packages` section and update both targets to depend on AudioKit:

```yaml
packages:
  AudioKit:
    url: https://github.com/AudioKit/AudioKit.git
    from: "5.6.0"
```

Add to each target's `dependencies` array:

```yaml
    dependencies:
      - package: AudioKit
```

**Step 2: Regenerate Xcode project**

Run: `cd /Users/david/Code/XCode/jubilant-dollop && xcodegen generate`
Expected: "Generated project FlappyBird" or similar success message.

**Step 3: Resolve packages**

Run: `xcodebuild -resolvePackageDependencies -project FlappyBird.xcodeproj`
Expected: AudioKit package resolves successfully.

**Step 4: Verify build**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird-macOS -destination 'platform=macOS' -quiet`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add project.yml FlappyBird.xcodeproj
git commit -m "chore: add AudioKit SPM dependency"
```

---

### Task 2: Create MusicEngine

**Files:**
- Create: `FlappyBird/Audio/MusicEngine.swift`

**Step 1: Create MusicEngine class**

This wraps AudioKit's engine and provides high-level play/stop/crossfade methods. It manages a mixer node graph with separate channels for melody, bass, percussion, harmony, and pads.

```swift
import AudioKit
import AVFoundation

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
```

**Step 2: Verify build**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird-macOS -destination 'platform=macOS' -quiet`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Audio/MusicEngine.swift
git commit -m "feat: add MusicEngine wrapping AudioKit"
```

---

### Task 3: Create SFXGenerator

**Files:**
- Create: `FlappyBird/Audio/SFXGenerator.swift`

**Step 1: Create SFXGenerator class**

Synthesizes the three sound effects using AudioKit oscillators and noise generators:

```swift
import AudioKit
import AVFoundation

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
```

**Step 2: Verify build**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird-macOS -destination 'platform=macOS' -quiet`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Audio/SFXGenerator.swift
git commit -m "feat: add SFXGenerator for synthesized sound effects"
```

---

### Task 4: Create MenuMusicProvider

**Files:**
- Create: `FlappyBird/Audio/MenuMusicProvider.swift`

**Step 1: Create MenuMusicProvider class**

Generates the progressive layered menu theme. Three layers that build up:
- Layer 1 (Title): Square wave melody + bass
- Layer 2 (Character Selection): + Percussion (kick/hi-hat via noise bursts) + harmony
- Layer 3 (Environment Selection): + Arpeggiated chords

```swift
import AudioKit
import AVFoundation

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
        l1m.volume = 0.25
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
                self.layer1Mixer?.volume = targetLayer >= 1 ? 0.25 * fraction : 0.25 * (1 - fraction)
                self.layer2Mixer?.volume = targetLayer >= 2 ? 0.2 * fraction : 0.2 * (1 - fraction)
                self.layer3Mixer?.volume = targetLayer >= 3 ? 0.15 * fraction : 0.15 * (1 - fraction)
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
```

**Step 2: Verify build**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird-macOS -destination 'platform=macOS' -quiet`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Audio/MenuMusicProvider.swift
git commit -m "feat: add MenuMusicProvider with progressive layered theme"
```

---

### Task 5: Create EnvironmentMusicProvider Protocol and Classic Implementation

**Files:**
- Create: `FlappyBird/Audio/EnvironmentMusicProvider.swift`
- Create: `FlappyBird/Audio/EnvironmentMusic/ClassicMusicProvider.swift`

**Step 1: Create the protocol**

```swift
import AudioKit

protocol EnvironmentMusicProvider {
    func start(engine: AudioEngine, mixer: Mixer)
    func stop()
}
```

**Step 2: Create ClassicMusicProvider**

Cheerful chiptune: bouncy square-wave melody, simple bass, ~140 BPM.

```swift
import AudioKit

class ClassicMusicProvider: EnvironmentMusicProvider {
    private var melodyOsc: Oscillator?
    private var bassOsc: Oscillator?
    private var trackMixer: Mixer?
    private var melodyTimer: Timer?
    private var bassTimer: Timer?

    private let beatDuration = 60.0 / 140.0

    // Cheerful C major melody
    private let melody: [AUValue] = [
        523.25, 587.33, 659.25, 783.99, 659.25, 587.33, 523.25, 0,
        659.25, 783.99, 880.00, 783.99, 659.25, 523.25, 587.33, 0,
        523.25, 659.25, 783.99, 1046.50, 880.00, 783.99, 659.25, 587.33,
        523.25, 587.33, 659.25, 523.25, 0, 523.25, 587.33, 659.25
    ]

    private let bass: [AUValue] = [
        130.81, 0, 130.81, 0, 174.61, 0, 174.61, 0,
        146.83, 0, 146.83, 0, 164.81, 0, 164.81, 0,
        130.81, 0, 174.61, 0, 196.00, 0, 164.81, 0,
        130.81, 0, 130.81, 0, 196.00, 0, 130.81, 0
    ]

    func start(engine: AudioEngine, mixer: Mixer) {
        melodyOsc = Oscillator(waveform: Table(.square))
        melodyOsc?.amplitude = 0.25
        bassOsc = Oscillator(waveform: Table(.triangle))
        bassOsc?.amplitude = 0.35

        let tm = Mixer([melodyOsc!, bassOsc!])
        tm.volume = 0.3
        trackMixer = tm
        mixer.addInput(tm)

        melodyOsc?.start()
        bassOsc?.start()

        var melodyIdx = 0
        melodyTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let note = self.melody[melodyIdx % self.melody.count]
            if note > 0 {
                self.melodyOsc?.frequency = note
                self.melodyOsc?.amplitude = 0.25
            } else {
                self.melodyOsc?.amplitude = 0
            }
            melodyIdx += 1
        }

        var bassIdx = 0
        bassTimer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
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
        melodyOsc?.stop()
        bassOsc?.stop()
        if let tm = trackMixer {
            // Removal handled by caller
        }
        trackMixer = nil
    }
}
```

**Step 3: Verify build and commit**

```bash
git add FlappyBird/Audio/EnvironmentMusicProvider.swift FlappyBird/Audio/EnvironmentMusic/ClassicMusicProvider.swift
git commit -m "feat: add EnvironmentMusicProvider protocol and Classic implementation"
```

---

### Task 6: Create Remaining Environment Music Providers

**Files:**
- Create: `FlappyBird/Audio/EnvironmentMusic/DesertMusicProvider.swift`
- Create: `FlappyBird/Audio/EnvironmentMusic/SpaceMusicProvider.swift`
- Create: `FlappyBird/Audio/EnvironmentMusic/JungleMusicProvider.swift`
- Create: `FlappyBird/Audio/EnvironmentMusic/UnderwaterMusicProvider.swift`
- Create: `FlappyBird/Audio/EnvironmentMusic/ArcticMusicProvider.swift`

Each follows the same pattern as `ClassicMusicProvider` but with different:
- Oscillator waveforms and note sequences
- Tempo (beatDuration)
- Musical character

**Step 1: Create DesertMusicProvider**

Western/frontier style: ~120 BPM, twangy filtered square wave lead, galloping rhythm pattern.

Key musical elements:
- Lead: Square wave with bandpass filter for "twangy" quality
- Bass: Triangle wave with dotted rhythm (galloping pattern: long-short-short)
- Use notes from D minor / D mixolydian for western feel
- Melody notes: D4, F4, G4, A4, Bb4 range

**Step 2: Create SpaceMusicProvider**

Atmospheric synth: ~100 BPM, slow ambient pads, deep sub-bass pulses, echoing arpeggios.

Key musical elements:
- Pad: Sine wave with very slow frequency modulation for shimmer
- Sub-bass: Low sine wave pulses (~50-80 Hz range)
- Arp: Sine wave arpeggios with long gaps between notes
- Use minor/suspended chords for spacey feel
- Notes: A minor pentatonic

**Step 3: Create JungleMusicProvider**

Tribal/rhythmic: ~130 BPM, percussion-heavy, pentatonic melody.

Key musical elements:
- Lead: Triangle wave, pentatonic scale (C, D, E, G, A)
- Heavy percussion: multiple noise bursts at different frequencies for drum-like sounds
- Syncopated rhythm patterns
- Bass: Strong triangle wave root notes

**Step 4: Create UnderwaterMusicProvider**

Dreamy/floaty: ~90 BPM, soft detuned pads, slow arpeggios.

Key musical elements:
- Two slightly detuned sine oscillators for "chorus" pad effect
- Very slow arpeggios with gaps
- Gentle, sustained notes
- Notes: Eb major / C minor for watery feel

**Step 5: Create ArcticMusicProvider**

Crystalline/sparse: ~105 BPM, high bell-like tones, sparse melody.

Key musical elements:
- Lead: Sine wave at high octave (C6-C7 range) for bell-like quality
- Very sparse melody with long silences between notes
- Gentle pad underneath (low sine wave)
- Notes: F major / D minor for cold, pristine feel

**Step 6: Verify build and commit**

```bash
git add FlappyBird/Audio/EnvironmentMusic/
git commit -m "feat: add Desert, Space, Jungle, Underwater, Arctic music providers"
```

---

### Task 7: Create EnvironmentMusicManager

**Files:**
- Create: `FlappyBird/Audio/EnvironmentMusicManager.swift`

**Step 1: Create EnvironmentMusicManager**

Manages starting/stopping environment music, mapping `GameEnvironment` to the correct provider:

```swift
import AudioKit

class EnvironmentMusicManager {
    static let shared = EnvironmentMusicManager()

    private let engine = AudioEngine()
    private let mixer = Mixer()
    private var currentProvider: EnvironmentMusicProvider?

    private init() {
        engine.output = mixer
    }

    func play(environment: GameEnvironment) {
        stop()
        let provider = musicProvider(for: environment)
        currentProvider = provider
        do {
            try engine.start()
        } catch {
            print("EnvironmentMusicManager start error: \(error)")
            return
        }
        provider.start(engine: engine, mixer: mixer)
    }

    func stop() {
        currentProvider?.stop()
        currentProvider = nil
        engine.stop()
    }

    private func musicProvider(for environment: GameEnvironment) -> EnvironmentMusicProvider {
        switch environment {
        case .classic:    return ClassicMusicProvider()
        case .desert:     return DesertMusicProvider()
        case .space:      return SpaceMusicProvider()
        case .jungle:     return JungleMusicProvider()
        case .underwater: return UnderwaterMusicProvider()
        case .arctic:     return ArcticMusicProvider()
        }
    }
}
```

**Step 2: Verify build and commit**

```bash
git add FlappyBird/Audio/EnvironmentMusicManager.swift
git commit -m "feat: add EnvironmentMusicManager to map environments to music"
```

---

### Task 8: Update AudioManager

**Files:**
- Modify: `FlappyBird/Audio/AudioManager.swift`

**Step 1: Rewrite AudioManager**

Replace the WAV-file-based implementation with one that delegates to `MenuMusicProvider`, `EnvironmentMusicManager`, and `SFXGenerator`:

```swift
import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private init() {}

    // MARK: - Menu Music

    func playMenuMusic(forState state: GameState) {
        switch state {
        case .title:
            EnvironmentMusicManager.shared.stop()
            MenuMusicProvider.shared.setLayer(1)
        case .characterSelection:
            MenuMusicProvider.shared.setLayer(2)
        case .environmentSelection:
            MenuMusicProvider.shared.setLayer(3)
        case .playing, .gameOver:
            break
        }
    }

    // MARK: - Gameplay Music

    func playEnvironmentMusic(for environment: GameEnvironment) {
        MenuMusicProvider.shared.stopPlaying()
        EnvironmentMusicManager.shared.play(environment: environment)
    }

    func stopMusic() {
        MenuMusicProvider.shared.stopPlaying()
        EnvironmentMusicManager.shared.stop()
    }

    // MARK: - Sound Effects

    func playFlapSound() {
        SFXGenerator.shared.playFlap()
    }

    func playScoreSound() {
        SFXGenerator.shared.playScore()
    }

    func playCollisionSound() {
        SFXGenerator.shared.playCollision()
    }
}
```

**Step 2: Verify build (will have errors — fix in next task)**

Note: This changes the SFX method signatures (removes `on scene:` parameter). Callers will be updated in Task 9.

**Step 3: Commit**

```bash
git add FlappyBird/Audio/AudioManager.swift
git commit -m "feat: rewrite AudioManager to use programmatic audio providers"
```

---

### Task 9: Update Callers (GameScene, Views)

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift` (lines 72, 225, 231, 243)
- Modify: `FlappyBird/Game/GameScene+Input.swift` (line 12)
- Modify: `FlappyBird/Views/TitleView.swift`
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift`
- Modify: `FlappyBird/Views/GameplayView.swift`

**Step 1: Update GameScene.swift**

In `setupScene()` (line 72), replace:
```swift
AudioManager.shared.playBGM()
```
with:
```swift
AudioManager.shared.playEnvironmentMusic(for: router.config.environment)
```

In `didBegin(_:)` (line 225), replace:
```swift
AudioManager.shared.playScoreSound(on: self)
```
with:
```swift
AudioManager.shared.playScoreSound()
```

In `didBegin(_:)` (line 231), replace:
```swift
AudioManager.shared.playCollisionSound(on: self)
```
with:
```swift
AudioManager.shared.playCollisionSound()
```

In `didBegin(_:)` (line 243), replace:
```swift
AudioManager.shared.stopBGM()
```
with:
```swift
AudioManager.shared.stopMusic()
```

**Step 2: Update GameScene+Input.swift**

In `handleJump` (line 12), replace:
```swift
AudioManager.shared.playFlapSound(on: self)
```
with:
```swift
AudioManager.shared.playFlapSound()
```

**Step 3: Add `.onAppear` music triggers to menu views**

In `TitleView.swift`, add to the `ZStack`:
```swift
.onAppear {
    AudioManager.shared.playMenuMusic(forState: .title)
}
```

In `CharacterSelectionView.swift`, add to the `ZStack`:
```swift
.onAppear {
    AudioManager.shared.playMenuMusic(forState: .characterSelection)
}
```

In `EnvironmentSelectionView.swift`, add to the `ZStack`:
```swift
.onAppear {
    AudioManager.shared.playMenuMusic(forState: .environmentSelection)
}
```

In `GameplayView.swift`, add to the game over overlay's "Menu" button action (after `router.returnToTitle()`):
```swift
AudioManager.shared.stopMusic()
```

**Step 4: Verify build**

Run: `xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird-macOS -destination 'platform=macOS' -quiet`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add FlappyBird/Game/GameScene.swift FlappyBird/Game/GameScene+Input.swift FlappyBird/Views/
git commit -m "feat: wire up menu music and synthesized SFX to all screens"
```

---

### Task 10: Remove Old WAV Files and Clean Up

**Files:**
- Delete: `FlappyBird/Resources/Sounds/bgm.wav`
- Delete: `FlappyBird/Resources/Sounds/flap.wav`
- Delete: `FlappyBird/Resources/Sounds/score.wav`
- Delete: `FlappyBird/Resources/Sounds/collision.wav`
- Modify: `project.yml` (remove Sounds resource reference if the directory is empty)

**Step 1: Remove WAV files**

```bash
rm FlappyBird/Resources/Sounds/*.wav
```

**Step 2: Update project.yml if needed**

If the Sounds directory is now empty, remove the resource reference:
```yaml
    resources:
      - path: FlappyBird/Resources/Assets.xcassets
      # Remove: - path: FlappyBird/Resources/Sounds
```

Or keep the directory if we want to use it for future audio assets.

**Step 3: Regenerate and verify build**

Run: `xcodegen generate && xcodebuild build -project FlappyBird.xcodeproj -scheme FlappyBird-macOS -destination 'platform=macOS' -quiet`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove old WAV sound files, use programmatic audio only"
```

---

### Task 11: Manual Testing & Tuning

**Not automatable — requires human testing.**

Run the app and verify:
1. Title screen plays upbeat melody + bass
2. Character selection adds percussion + harmony
3. Environment selection adds arpeggiated chords
4. Going back between menu screens removes/adds layers smoothly
5. Each environment plays its unique music during gameplay
6. Flap sound is a soft whoosh (not a beep)
7. Score sound is a pleasant ascending chime
8. Collision sound is a satisfying low thud
9. Music crossfades properly between menu → gameplay
10. Game over stops music
11. Returning to menu from game over restarts menu music

Tune volumes, tempos, and note sequences as needed during this step.
