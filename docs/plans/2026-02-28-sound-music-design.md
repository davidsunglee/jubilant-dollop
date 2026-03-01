# Sound & Music Overhaul Design

## Overview

Replace the current single-BGM + WAV-file audio system with a fully programmatic audio engine using AudioKit. Add dynamic music to all menu screens, environment-specific gameplay music, and synthesized sound effects.

## Technical Approach

**Framework:** AudioKit (SPM dependency)
**Current audio files:** All 4 WAV files in `Resources/Sounds/` will be removed. Everything generated in code.

## Architecture

### Components

- **`MusicEngine`** — Wraps AudioKit engine, oscillators, and sequencer. Provides play/stop/crossfade methods. Manages the AudioKit node graph.
- **`AudioManager` (updated)** — Singleton that delegates to `MusicEngine` for BGM and `SFXGenerator` for effects. Tracks current screen state.
- **`MenuMusicProvider`** — Generates progressive layered menu theme across title/character/environment screens.
- **`EnvironmentMusicProvider`** — Protocol with 6 implementations, one per environment. Each generates unique gameplay music.
- **`SFXGenerator`** — Synthesizes sound effects (flap, score, collision) using AudioKit oscillators and filters.

### Data Flow

```
Screen change → GameRouter notifies AudioManager → AudioManager calls MusicEngine
    → MusicEngine crossfades to appropriate track from the relevant provider
```

## Menu Music: Progressive Layering

One base theme (C major, ~140 BPM, upbeat chiptune) that builds across screens:

| Screen | Layers |
|---|---|
| **Title** | Square-wave melody + light bass line. Simple, catchy 4-bar loop. |
| **Character Selection** | + Percussion (kick + hi-hat) + harmony voice (triangle wave, thirds/fifths) |
| **Environment Selection** | + Arpeggiated chords. Full arrangement creates anticipation. |

**Transitions:** Layers fade in/out over ~0.5s. Going back removes layers. Base tempo/key stays constant.

## Environment Music

| Environment | Style | Key Elements |
|---|---|---|
| **Classic** | Cheerful chiptune | Bouncy square-wave melody, simple bass, ~140 BPM. Retro game feel. |
| **Desert** | Western/frontier | Twangy filtered square-wave lead, galloping rhythm, ~120 BPM. Spaghetti-western feel. |
| **Space** | Atmospheric synth | Slow ambient pads, deep sub-bass pulses, echoing arpeggios, ~100 BPM. Ethereal. |
| **Jungle** | Tribal/rhythmic | Synth percussion-heavy, pentatonic melody, ~130 BPM. Energetic. |
| **Underwater** | Dreamy/floaty | Soft detuned pads, slow arpeggios with reverb/delay, ~90 BPM. Calm. |
| **Arctic** | Crystalline/sparse | High bell-like tones, sparse melody, gentle reverb, ~105 BPM. Cold. |

**Transition:** Menu music fades out over ~1s, environment music fades in when gameplay starts.

## Sound Effects

All synthesized via AudioKit:

| SFX | Technique |
|---|---|
| **Flap (soft whoosh)** | White noise burst (~50ms), bandpass sweep high→low, fast attack + short decay. Light and non-fatiguing. |
| **Score** | Ascending two-note chime (major third), sine wave, quick decay. Bright and satisfying. |
| **Collision** | Low-frequency noise burst with distortion, ~200ms decay, descending pitch. Impactful thud. |

## Integration Points

- `GameRouter` state changes trigger `AudioManager` to switch music
- `GameScene.handleJump()` triggers flap SFX via `AudioManager`
- `GameScene` collision detection triggers score/collision SFX
- Remove existing WAV files from `Resources/Sounds/`
- Add AudioKit via Swift Package Manager
