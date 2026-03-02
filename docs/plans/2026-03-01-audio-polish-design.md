# Audio Polish Design

## Overview

Polish three audio elements: flap sound effect, score sound effect, and arctic environment music. All audio is programmatically synthesized via AudioKit.

## 1. Flap Sound — Soft Puff of Air

**File:** `SFXGenerator.swift` — `playFlap()`

**Current:** White noise burst with bandpass filter (3000Hz center, 1000Hz BW), swept 3000→500Hz over ~60ms, amplitude 0.4→0.

**Changes:**
- Lower initial bandpass center: 3000Hz → 1200Hz
- Widen bandwidth: 1000Hz → 1500Hz
- Sweep range: 1200Hz → 400Hz
- Reduce initial amplitude: 0.4 → 0.25
- Extend duration: ~60ms → ~90ms
- Slower decay steps for gentler tail

**Result:** Soft cushion of air rather than sharp whoosh.

## 2. Score Sound — Gentle Bell Chime

**File:** `SFXGenerator.swift` — `playScore()`

**Current:** Two sine oscillators — 880Hz (A5) then 1109Hz (C#6) 80ms apart, amplitude 0.15 each, fading over ~200ms.

**Changes:**
- Lower frequencies: 523Hz (C5) → 659Hz (E5) — major third, one octave lower
- Reduce amplitude: 0.15 → 0.08 per oscillator
- Add gentle 20ms fade-in on each note
- Extend decay: ~200ms → ~350ms
- Smoother fade: 12 decay steps instead of 8

**Result:** Warm, mellow bell rather than bright chime.

## 3. Arctic Environment Music — Brisk & Sparkling

**File:** `ArcticMusicProvider.swift`

**Current:** 105 BPM, sparse sine bells (C6-C7), slow pad changing every 4 beats. Cold and somber.

**Changes:**
- BPM: 105 → 120
- Bell melody: C major pentatonic in C5-G6 range (lower, less piercing), fewer rests, more arpeggiated patterns, amplitude 0.18 → 0.20
- New rhythmic pulse: triangle-wave bass on beats 1 & 3 (C3-G3, ~0.12 amplitude, ~200ms decay)
- Pad: change every 2 beats instead of 4, add shimmer via ±1.5Hz frequency modulation
- Track volume stays at 0.4

**Result:** Icy landscape with forward momentum — like gliding across a frozen lake.

## Files Modified

| File | Change |
|------|--------|
| `FlappyBird/Audio/SFXGenerator.swift` | Update `playFlap()` and `playScore()` |
| `FlappyBird/Audio/ArcticMusicProvider.swift` | Rewrite music generation |
