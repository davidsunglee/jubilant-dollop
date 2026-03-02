# Ready State Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a "ready" state so the character bobs in place with no gravity until the player's first tap starts gameplay.

**Architecture:** Add `isReady` boolean to `GameScene`. On scene load, gravity is zero and players bob. First tap transitions to active gameplay by enabling gravity, starting obstacle spawning, and applying the jump impulse to the tapping player.

**Tech Stack:** Swift, SpriteKit (SKAction for bob animation)

**Design doc:** `docs/plans/2026-03-01-ready-state-design.md`

---

### Task 1: Add bob animation to PlayerNode

**Files:**
- Modify: `FlappyBird/Game/PlayerNode.swift:39` (after the `jump` method)

**Step 1: Add `startBobAnimation()` and `stopBobAnimation()` methods**

Add these two methods after the `jump` method at line 44:

```swift
func startBobAnimation() {
    let bobUp = SKAction.moveBy(x: 0, y: 12, duration: 0.4)
    bobUp.timingMode = .easeInEaseOut
    let bobDown = SKAction.moveBy(x: 0, y: -12, duration: 0.4)
    bobDown.timingMode = .easeInEaseOut
    let bobCycle = SKAction.sequence([bobUp, bobDown])
    run(SKAction.repeatForever(bobCycle), withKey: "bob")
}

func stopBobAnimation() {
    removeAction(forKey: "bob")
}
```

**Step 2: Build the project**

Run: Cmd+B in Xcode
Expected: Builds successfully, no errors

**Step 3: Commit**

```bash
git add FlappyBird/Game/PlayerNode.swift
git commit -m "feat: add bob animation methods to PlayerNode"
```

---

### Task 2: Add ready state to GameScene

**Files:**
- Modify: `FlappyBird/Game/GameScene.swift:9` (properties section)
- Modify: `FlappyBird/Game/GameScene.swift:55-73` (setupScene method)
- Modify: `FlappyBird/Game/GameScene.swift:77-79` (setupWorld method)
- Modify: `FlappyBird/Game/GameScene.swift:162-163` (update method)

**Step 1: Add `isReady` property**

At line 9, after `var isGameActive: Bool = false`, add:

```swift
var isReady: Bool = false
```

**Step 2: Modify `setupScene()` to enter ready state instead of active gameplay**

Replace lines 66-72 (from `setupWorld()` through `isGameActive = true`) with:

```swift
setupWorld()
setupPlayers()
setupBackground()
setupBoundaries()

// Enter ready state: no gravity, no obstacles, players bob
isReady = true
isGameActive = false
for player in players {
    player.startBobAnimation()
}
AudioManager.shared.playEnvironmentMusic(for: router.config.environment)
```

Key changes: `startSpawning()` removed, `isGameActive = true` replaced with `isReady = true`, bob animation started on each player.

**Step 3: Modify `setupWorld()` to start with zero gravity**

Replace line 78:
```swift
physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
```
With:
```swift
physicsWorld.gravity = CGVector(dx: 0, dy: 0)
```

**Step 4: Add `activateGameplay()` method**

Add this new method after `setupBoundaries()` (after line 158):

```swift
// MARK: - Ready → Active Transition

func activateGameplay() {
    guard isReady else { return }
    isReady = false
    isGameActive = true

    physicsWorld.gravity = CGVector(dx: 0, dy: gravity)

    for player in players {
        player.stopBobAnimation()
    }

    startSpawning()
}
```

**Step 5: Update `update()` to scroll background during ready state**

Replace line 163:
```swift
guard isGameActive else { return }
```
With:
```swift
guard isGameActive || isReady else { return }
```

Also, wrap the player X-lock and rotation code (lines 174-189) so it only runs during active gameplay. The full update method becomes:

```swift
override func update(_ currentTime: TimeInterval) {
    guard isGameActive || isReady else { return }

    if lastUpdateTime == 0 {
        lastUpdateTime = currentTime
    }
    let dt = currentTime - lastUpdateTime
    lastUpdateTime = currentTime

    parallaxBackground?.update(deltaTime: dt)

    guard isGameActive else { return }

    // Lock player X positions
    for player in players {
        guard player.isAlive else { continue }
        let targetX: CGFloat
        if router.config.playerCount == 2 {
            targetX = player.playerIndex == 1 ? size.width * 0.25 : size.width * 0.75
        } else {
            targetX = size.width * 0.3
        }
        player.position.x = targetX

        // Clamp rotation based on velocity
        if let vy = player.physicsBody?.velocity.dy {
            let rotation = max(-0.5, min(0.5, vy / 500))
            player.zRotation = rotation
        }
    }
}
```

**Step 6: Build the project**

Run: Cmd+B in Xcode
Expected: Builds successfully

**Step 7: Commit**

```bash
git add FlappyBird/Game/GameScene.swift
git commit -m "feat: add ready state with zero gravity and background scroll"
```

---

### Task 3: Update input handling for ready state

**Files:**
- Modify: `FlappyBird/Game/GameScene+Input.swift` (entire file)

**Step 1: Update `touchesBegan` and `keyDown` to handle ready state**

Replace the entire file content with:

```swift
import SpriteKit

// MARK: - Input Handling
extension GameScene {

    func handleJump(forPlayer playerIndex: Int) {
        guard isGameActive else { return }
        guard playerIndex >= 1 && playerIndex <= players.count else { return }
        let player = players[playerIndex - 1]
        guard player.isAlive else { return }
        player.jump(impulse: jumpImpulse)
        AudioManager.shared.playFlapSound()
    }

    private func handleInput(forPlayer playerIndex: Int) {
        if isReady {
            activateGameplay()
            handleJump(forPlayer: playerIndex)
        } else if isGameActive {
            handleJump(forPlayer: playerIndex)
        }
    }

    // MARK: - iOS / iPadOS Touch Input
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if router.config.playerCount == 1 {
                handleInput(forPlayer: 1)
            } else {
                // 2P: left half = P1, right half = P2
                if location.x < size.width / 2 {
                    handleInput(forPlayer: 1)
                } else {
                    handleInput(forPlayer: 2)
                }
            }
        }
    }
    #endif

    // MARK: - macOS Keyboard Input
    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        // Intentionally do not call super to suppress macOS beep on unhandled keys
        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return }

        if router.config.playerCount == 1 {
            if chars == " " {
                handleInput(forPlayer: 1)
            }
        } else {
            switch chars {
            case "a":
                handleInput(forPlayer: 1)
            case "l":
                handleInput(forPlayer: 2)
            default:
                break
            }
        }
    }
    #endif
}
```

Key changes:
- New `handleInput(forPlayer:)` method routes through ready → active transition
- `touchesBegan` and `keyDown` no longer guard on `isGameActive` at the top level — they delegate to `handleInput` which checks both states
- `handleJump` still guards on `isGameActive` for safety

**Step 2: Build the project**

Run: Cmd+B in Xcode
Expected: Builds successfully

**Step 3: Commit**

```bash
git add FlappyBird/Game/GameScene+Input.swift
git commit -m "feat: handle ready-state input to activate gameplay on first tap"
```

---

### Task 4: Manual testing

**Step 1: Run the app (1P mode)**

1. Launch the app
2. Select a character, tap an environment
3. Verify: character bobs gently up and down at center of screen
4. Verify: background scrolls, no obstacles visible
5. Verify: music is playing
6. Tap the screen
7. Verify: character jumps, gravity kicks in, obstacles start spawning
8. Verify: gameplay feels smooth and natural from this point

**Step 2: Run the app (2P mode)**

1. Launch in 2P mode
2. Select characters, tap an environment
3. Verify: both characters bob independently
4. Have one player tap
5. Verify: tapping player jumps, other player starts falling, obstacles spawn
6. Verify: both players are now in active gameplay

**Step 3: Edge case — rapid taps during transition**

1. Start a new game
2. Tap rapidly during the ready state
3. Verify: only one activation occurs (no double-spawning or glitches)

**Step 4: Commit final state if any tweaks were made**

```bash
git add -A
git commit -m "feat: ready state for smooth game start"
```
