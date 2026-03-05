# Flappy Bird

A feature-rich Flappy Bird game built natively in Swift for iOS, iPadOS, and macOS. Navigate through obstacle gaps as one of six procedurally rendered characters across six themed environments, with support for local two-player split-screen multiplayer.

## Features

- **6 Playable Characters** — Avian, Winged Pig, Flying Squirrel, Pegasus, Winged Turtle, and Bat, each with unique physics bodies and animated wing flapping
- **6 Themed Environments** — Classic, Jungle, Underwater, Arctic, Desert, and Space, each with parallax scrolling backgrounds and environment-specific music
- **Local Multiplayer** — Two-player split-screen on a single device with independent scoring and lives
- **Procedural Rendering** — All characters and environments are drawn programmatically using SpriteKit shape nodes (no image assets)
- **Synthesized Audio** — Sound effects generated via AudioKit; background music streamed per-environment via AVFoundation
- **Cross-Platform** — Unified codebase targeting iOS/iPadOS (touch) and macOS (keyboard) with platform-specific input normalization

## Tech Stack

| Layer | Technology |
|---|---|
| UI & Menus | SwiftUI |
| Game Engine | SpriteKit |
| Background Music | AVFoundation |
| Sound Effects | AudioKit + SoundpipeAudioKit |
| Build System | XcodeGen |

## Requirements

- Xcode 15.0+
- iOS 17.0+ / macOS 14.0+
- Swift 5.9+

## Project Structure

```
FlappyBird/
├── App/                        # Entry point
├── Models/                     # GameCharacter, GameEnvironment, GameState, GameConfig, PhysicsCategory
├── ViewModels/                 # GameRouter (state management)
├── Views/                      # SwiftUI screens (Title, CharacterSelection, EnvironmentSelection, Gameplay)
├── Game/                       # SpriteKit core (GameScene, PlayerNode, ObstacleNode, renderers)
│   └── Environments/           # Per-environment parallax renderers (Classic, Jungle, Underwater, Arctic, Desert, Space)
└── Audio/                      # AudioManager, SFXGenerator, MusicEngine, per-environment music providers
    └── EnvironmentMusic/       # ClassicMusic, JungleMusic, UnderwaterMusic, ArcticMusic, DesertMusic, SpaceMusic
```

## Game Flow

1. **Title Screen** — Select 1 Player or 2 Players
2. **Character Selection** — Pick a character for each player from a 3x2 grid of live-preview cards
3. **Environment Selection** — Tap an environment card to start the game
4. **Gameplay** — Tap (iOS) or press Space/A/L (macOS) to flap; avoid obstacles, score points, earn bonus lives every 100 points
5. **Game Over** — View final scores; replay or return to title

## Gameplay Mechanics

- **Physics**: Constant gravity with impulse-based jumping; velocity reset before each jump to prevent momentum stacking
- **Health**: 3 lives per player; collisions trigger a 1.4-second invincibility window with flash animation
- **Boundaries**: Hard ceiling clamp at the top of the screen; instant death at ground level
- **Scoring**: +1 per obstacle gap cleared; bonus life at every 100-point milestone
- **Difficulty**: Consistent obstacle spacing and speed (endless arcade mode)

## Multiplayer

Two-player mode uses single-scene partitioning — both players share one `SKScene` with a visual divider at the center.

| | Player 1 | Player 2 |
|---|---|---|
| **Position** | 25% screen width | 75% screen width |
| **iOS Input** | Tap left half | Tap right half |
| **macOS Input** | A key | L key |
| **Lives** | Independent | Independent |
| **Score** | Independent | Independent |

The game ends when both players have lost all lives.

## Controls

| Platform | 1 Player | 2 Players |
|---|---|---|
| iOS / iPadOS | Tap anywhere | Left half = P1, Right half = P2 |
| macOS | Space | A = P1, L = P2 |
