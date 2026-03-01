# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flappy Bird clone built entirely in Swift with **no external image or sound assets** — all visuals are drawn with SpriteKit shape nodes and all audio is generated procedurally via AudioKit. Supports 1P and 2P local split-screen. iOS 17+ and macOS 14+ from a unified codebase.

## Build & Run

The project uses **XcodeGen** — `project.yml` is the source of truth, not the `.xcodeproj`.

```bash
# Regenerate Xcode project after changing targets/settings/dependencies
xcodegen generate

# Build from command line
xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird-iOS -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird-macOS build
```

There are no test targets. No linter is configured.

## Dependencies

Managed via Swift Package Manager (declared in `project.yml`):
- **AudioKit** 5.6+ — audio engine, oscillators, mixers, faders
- **SoundpipeAudioKit** 5.6+ — filters (band-pass, low-pass, high-pass)

## Architecture

**MVVM + Router pattern** with a central `GameRouter` state machine:

- **GameRouter** (`ViewModels/GameRouter.swift`) — single `ObservableObject` owning all app state (`state`, `config`, `scores`, `lives`, `playerAlive`). All navigation and state transitions flow through it.
- **ContentView** holds `@StateObject var router` and switches views based on `router.state`: `title → characterSelection → environmentSelection → playing → gameOver`.

**Key architectural patterns:**

- **Protocol-based strategies** — `EnvironmentRenderer` protocol (6 implementations in `Game/Environments/`) for per-environment visuals; `EnvironmentMusicProvider` protocol (in `Audio/EnvironmentMusic/`) for per-environment procedural music.
- **Singleton services** — `AudioManager.shared`, `MenuMusicProvider.shared`, `EnvironmentMusicManager.shared`, `SFXGenerator.shared`, `MusicEngine.shared`.
- **GameScene decomposition** — `GameScene.swift` (lifecycle/physics), `GameScene+Spawning.swift` (pipe spawning), `GameScene+Input.swift` (platform-conditional touch/keyboard input via `#if os(iOS)` / `#if os(macOS)`).
- **Programmatic rendering** — `CharacterRenderer.swift` draws all 6 character sprites as `SKShapeNode` paths; `CharacterRenderer.renderToImage()` with caching converts them to `UIImage`/`NSImage` for SwiftUI previews. `EnvironmentPreviewRenderer` does the same for environment selection cards.
- **Parallax scrolling** — `ParallaxBackground` manages tiling `ParallaxLayer` objects with configurable `speedMultiplier`.

## Key Data Types

- `GameCharacter` / `GameEnvironment` — enums defining the 6 characters and 6 environments, each with a computed `.renderer` or `.musicProvider` property.
- `GameConfig` — holds selected characters, environment, and player count.
- `GameState` — enum for router state machine.
- `PhysicsCategory` — SpriteKit physics bitmask constants.

## Design Reference

`FlappyBird.md` in the repo root is the full game design specification (physics, architecture, input, audio, multiplayer). `docs/plans/` contains feature implementation plans.
