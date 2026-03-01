# Animal Sprite Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace generic colored-blob character sprites with detailed multi-shape composite animals that are visually recognizable.

**Architecture:** Each character gets a dedicated builder method in `CharacterRenderer` that constructs the animal from multiple `SKShapeNode` children. SF Symbols are removed. The character selection screen renders sprite previews via off-screen `SKView` snapshots.

**Tech Stack:** SpriteKit (SKShapeNode, SKNode, SKAction), SwiftUI, cross-platform (iOS/macOS)

---

### Task 1: Scaffold the new CharacterRenderer structure

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift`

**Step 1: Replace createNode with switch-to-builders pattern**

Replace the entire `CharacterRenderer` class with the new structure. For now, each builder returns a simple placeholder (the old circle/rect) so nothing breaks while we iterate.

```swift
import SpriteKit

class CharacterRenderer {
    static func createNode(for character: GameCharacter) -> SKNode {
        let container = SKNode()
        container.name = "characterVisual"

        switch character {
        case .avian:          buildAvian(in: container)
        case .wingedPig:      buildWingedPig(in: container)
        case .flyingSquirrel: buildFlyingSquirrel(in: container)
        case .pegasus:        buildPegasus(in: container)
        case .wingedTurtle:   buildWingedTurtle(in: container)
        case .bat:            buildBat(in: container)
        }

        return container
    }

    // MARK: - Avian
    private static func buildAvian(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 15)
        body.fillColor = .yellow
        body.strokeColor = .orange
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 12, height: 9))
        wing.fillColor = SKColor.yellow.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -9, y: 5)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 6, duration: 0.15)
    }

    // MARK: - Winged Pig
    private static func buildWingedPig(in container: SKNode) {
        let body = SKShapeNode(rectOf: CGSize(width: 36, height: 28), cornerRadius: 8)
        body.fillColor = .systemPink
        body.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 8))
        wing.fillColor = SKColor.systemPink.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -11, y: 4)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 4, duration: 0.12)
    }

    // MARK: - Flying Squirrel
    private static func buildFlyingSquirrel(in container: SKNode) {
        let body = SKShapeNode(rectOf: CGSize(width: 40, height: 20), cornerRadius: 6)
        body.fillColor = .brown
        body.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 16, height: 6))
        wing.fillColor = SKColor.brown.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -12, y: 3)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 3, duration: 0.25)
    }

    // MARK: - Pegasus
    private static func buildPegasus(in container: SKNode) {
        let body = SKShapeNode(rectOf: CGSize(width: 38, height: 32), cornerRadius: 4)
        body.fillColor = .white
        body.strokeColor = .lightGray
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 15, height: 10))
        wing.fillColor = SKColor.white.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -11, y: 5)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 10, duration: 0.2)
    }

    // MARK: - Winged Turtle
    private static func buildWingedTurtle(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 17)
        body.fillColor = .green
        body.strokeColor = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 9))
        wing.fillColor = SKColor.green.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -10, y: 3)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 5, duration: 0.08)
    }

    // MARK: - Bat
    private static func buildBat(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 12)
        body.fillColor = .darkGray
        body.strokeColor = .black
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 10, height: 7))
        wing.fillColor = SKColor.darkGray.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -7, y: 4)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 8, duration: 0.18)
    }

    // MARK: - Wing Animation Helper
    private static func addWingAnimation(to wing: SKShapeNode, range: CGFloat, duration: TimeInterval) {
        let flapUp = SKAction.moveBy(x: 0, y: range, duration: duration)
        let flapDown = SKAction.moveBy(x: 0, y: -range, duration: duration)
        let flap = SKAction.sequence([flapUp, flapDown])
        wing.run(SKAction.repeatForever(flap))
    }
}
```

**Step 2: Build and run to verify no regressions**

Run: Build the project in Xcode (Cmd+B) or `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds with no errors. Game plays identically to before (sprites look the same as old code, just reorganized).

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "refactor: scaffold per-character builder methods in CharacterRenderer"
```

---

### Task 2: Build detailed Avian (bird) sprite

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (the `buildAvian` method)

**Step 1: Replace the placeholder buildAvian with the detailed composite**

```swift
private static func buildAvian(in container: SKNode) {
    // Body - round yellow
    let body = SKShapeNode(circleOfRadius: 13)
    body.fillColor = .yellow
    body.strokeColor = .orange
    body.lineWidth = 1.5
    container.addChild(body)

    // Belly - lighter oval
    let belly = SKShapeNode(ellipseOf: CGSize(width: 16, height: 12))
    belly.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1)
    belly.strokeColor = .clear
    belly.position = CGPoint(x: 1, y: -2)
    container.addChild(belly)

    // Eye - white with black pupil
    let eye = SKShapeNode(circleOfRadius: 4)
    eye.fillColor = .white
    eye.strokeColor = .darkGray
    eye.lineWidth = 0.5
    eye.position = CGPoint(x: 6, y: 4)
    container.addChild(eye)

    let pupil = SKShapeNode(circleOfRadius: 2)
    pupil.fillColor = .black
    pupil.strokeColor = .clear
    pupil.position = CGPoint(x: 7, y: 4)
    container.addChild(pupil)

    // Beak - orange triangle (using path)
    let beakPath = CGMutablePath()
    beakPath.move(to: CGPoint(x: 12, y: 2))
    beakPath.addLine(to: CGPoint(x: 20, y: 0))
    beakPath.addLine(to: CGPoint(x: 12, y: -2))
    beakPath.closeSubpath()
    let beak = SKShapeNode(path: beakPath)
    beak.fillColor = .orange
    beak.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1)
    beak.lineWidth = 1
    container.addChild(beak)

    // Tail feathers - 2 small ellipses fanning left
    for i in 0..<2 {
        let feather = SKShapeNode(ellipseOf: CGSize(width: 10, height: 4))
        feather.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1)
        feather.strokeColor = .orange
        feather.lineWidth = 0.5
        feather.position = CGPoint(x: -14, y: CGFloat(i) * 4 - 2)
        feather.zRotation = CGFloat(i) * 0.3 - 0.15
        container.addChild(feather)
    }

    // Wing - feathered ellipse
    let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 8))
    wing.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 0.9)
    wing.strokeColor = .orange
    wing.lineWidth = 0.5
    wing.position = CGPoint(x: -4, y: 6)
    wing.name = "wing"
    container.addChild(wing)
    addWingAnimation(to: wing, range: 6, duration: 0.15)
}
```

**Step 2: Build and run, visually verify the bird looks like a bird**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds. Bird character shows yellow body, beak, eye, tail feathers, flapping wing.

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "feat: build detailed avian sprite with beak, eye, tail feathers"
```

---

### Task 3: Build detailed Winged Pig sprite

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (the `buildWingedPig` method)

**Step 1: Replace placeholder with detailed composite**

```swift
private static func buildWingedPig(in container: SKNode) {
    // Body - rounded pink rectangle
    let body = SKShapeNode(rectOf: CGSize(width: 32, height: 26), cornerRadius: 10)
    body.fillColor = .systemPink
    body.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
    body.lineWidth = 1.5
    container.addChild(body)

    // Snout - lighter pink circle
    let snout = SKShapeNode(circleOfRadius: 6)
    snout.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.75, alpha: 1)
    snout.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
    snout.lineWidth = 1
    snout.position = CGPoint(x: 12, y: -2)
    container.addChild(snout)

    // Nostrils - two small dots
    for dx in [-2, 2] as [CGFloat] {
        let nostril = SKShapeNode(circleOfRadius: 1.5)
        nostril.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        nostril.strokeColor = .clear
        nostril.position = CGPoint(x: 12 + dx, y: -2)
        container.addChild(nostril)
    }

    // Eyes - beady
    for dy in [4] as [CGFloat] {
        let eye = SKShapeNode(circleOfRadius: 2.5)
        eye.fillColor = .white
        eye.strokeColor = .darkGray
        eye.lineWidth = 0.5
        eye.position = CGPoint(x: 6, y: dy)
        container.addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: 1.5)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: 7, y: dy)
        container.addChild(pupil)
    }

    // Ears - two small triangles on top
    for dx in [-5, 5] as [CGFloat] {
        let earPath = CGMutablePath()
        earPath.move(to: CGPoint(x: dx - 3, y: 13))
        earPath.addLine(to: CGPoint(x: dx, y: 20))
        earPath.addLine(to: CGPoint(x: dx + 3, y: 13))
        earPath.closeSubpath()
        let ear = SKShapeNode(path: earPath)
        ear.fillColor = .systemPink
        ear.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        ear.lineWidth = 1
        container.addChild(ear)
    }

    // Curly tail - small circle on left
    let tail = SKShapeNode(circleOfRadius: 4)
    tail.fillColor = .systemPink
    tail.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
    tail.lineWidth = 1
    tail.position = CGPoint(x: -19, y: 2)
    container.addChild(tail)

    // Wings - comically small
    let wing = SKShapeNode(ellipseOf: CGSize(width: 10, height: 6))
    wing.fillColor = SKColor.systemPink.withAlphaComponent(0.8)
    wing.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
    wing.lineWidth = 0.5
    wing.position = CGPoint(x: -6, y: 8)
    wing.name = "wing"
    container.addChild(wing)
    addWingAnimation(to: wing, range: 4, duration: 0.12)
}
```

**Step 2: Build and visually verify**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds. Pig shows pink body, snout with nostrils, ears, curly tail, tiny flapping wings.

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "feat: build detailed winged pig sprite with snout, ears, curly tail"
```

---

### Task 4: Build detailed Flying Squirrel sprite

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (the `buildFlyingSquirrel` method)

**Step 1: Replace placeholder with detailed composite**

```swift
private static func buildFlyingSquirrel(in container: SKNode) {
    // Body - wide brown ellipse
    let body = SKShapeNode(ellipseOf: CGSize(width: 34, height: 18))
    body.fillColor = .brown
    body.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
    body.lineWidth = 1.5
    container.addChild(body)

    // Belly - lighter brown
    let belly = SKShapeNode(ellipseOf: CGSize(width: 22, height: 10))
    belly.fillColor = SKColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)
    belly.strokeColor = .clear
    belly.position = CGPoint(x: 0, y: -2)
    container.addChild(belly)

    // Head - small rounded shape extending right
    let head = SKShapeNode(circleOfRadius: 8)
    head.fillColor = .brown
    head.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
    head.lineWidth = 1
    head.position = CGPoint(x: 16, y: 4)
    container.addChild(head)

    // Big round eyes (squirrels have large eyes)
    let eye = SKShapeNode(circleOfRadius: 3.5)
    eye.fillColor = .white
    eye.strokeColor = .darkGray
    eye.lineWidth = 0.5
    eye.position = CGPoint(x: 19, y: 6)
    container.addChild(eye)

    let pupil = SKShapeNode(circleOfRadius: 2)
    pupil.fillColor = .black
    pupil.strokeColor = .clear
    pupil.position = CGPoint(x: 20, y: 6)
    container.addChild(pupil)

    // Small nose
    let nose = SKShapeNode(circleOfRadius: 1.5)
    nose.fillColor = SKColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1)
    nose.strokeColor = .clear
    nose.position = CGPoint(x: 23, y: 3)
    container.addChild(nose)

    // Bushy tail - overlapping ellipses curving up-left
    for i in 0..<3 {
        let segment = SKShapeNode(ellipseOf: CGSize(width: 8, height: 6))
        segment.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 0.9)
        segment.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
        segment.lineWidth = 0.5
        segment.position = CGPoint(x: -17 - CGFloat(i) * 3, y: CGFloat(i) * 5)
        container.addChild(segment)
    }

    // Membrane wings - flat wide shape
    let wing = SKShapeNode(ellipseOf: CGSize(width: 20, height: 5))
    wing.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.7)
    wing.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 0.5)
    wing.lineWidth = 0.5
    wing.position = CGPoint(x: 0, y: 10)
    wing.name = "wing"
    container.addChild(wing)
    addWingAnimation(to: wing, range: 3, duration: 0.25)
}
```

**Step 2: Build and visually verify**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds. Squirrel shows brown body, head with big eyes, bushy tail, membrane wings.

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "feat: build detailed flying squirrel sprite with big eyes, bushy tail"
```

---

### Task 5: Build detailed Pegasus sprite

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (the `buildPegasus` method)

**Step 1: Replace placeholder with detailed composite**

```swift
private static func buildPegasus(in container: SKNode) {
    // Body - white rectangle
    let body = SKShapeNode(rectOf: CGSize(width: 32, height: 22), cornerRadius: 6)
    body.fillColor = .white
    body.strokeColor = .lightGray
    body.lineWidth = 1.5
    container.addChild(body)

    // Neck + Head - elongated upward-right
    let neck = SKShapeNode(rectOf: CGSize(width: 8, height: 16), cornerRadius: 3)
    neck.fillColor = .white
    neck.strokeColor = .lightGray
    neck.lineWidth = 1
    neck.position = CGPoint(x: 14, y: 12)
    neck.zRotation = -0.3
    container.addChild(neck)

    let head = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
    head.fillColor = .white
    head.strokeColor = .lightGray
    head.lineWidth = 1
    head.position = CGPoint(x: 20, y: 18)
    container.addChild(head)

    // Eye
    let eye = SKShapeNode(circleOfRadius: 2)
    eye.fillColor = .black
    eye.strokeColor = .clear
    eye.position = CGPoint(x: 23, y: 19)
    container.addChild(eye)

    // Pointed ears
    for dx in [-2, 2] as [CGFloat] {
        let earPath = CGMutablePath()
        earPath.move(to: CGPoint(x: 18 + dx, y: 22))
        earPath.addLine(to: CGPoint(x: 19 + dx, y: 28))
        earPath.addLine(to: CGPoint(x: 21 + dx, y: 22))
        earPath.closeSubpath()
        let ear = SKShapeNode(path: earPath)
        ear.fillColor = .white
        ear.strokeColor = .lightGray
        ear.lineWidth = 0.5
        container.addChild(ear)
    }

    // Flowing tail - overlapping curved ellipses
    for i in 0..<3 {
        let tailPiece = SKShapeNode(ellipseOf: CGSize(width: 10, height: 5))
        tailPiece.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 0.9)
        tailPiece.strokeColor = .lightGray
        tailPiece.lineWidth = 0.5
        tailPiece.position = CGPoint(x: -18 - CGFloat(i) * 4, y: CGFloat(i) * 3 - 2)
        tailPiece.zRotation = CGFloat(i) * 0.2
        container.addChild(tailPiece)
    }

    // Legs - two small rectangles at bottom
    for dx in [-6, 6] as [CGFloat] {
        let leg = SKShapeNode(rectOf: CGSize(width: 3, height: 8), cornerRadius: 1)
        leg.fillColor = .white
        leg.strokeColor = .lightGray
        leg.lineWidth = 0.5
        leg.position = CGPoint(x: dx, y: -15)
        container.addChild(leg)
    }

    // Large angelic wings
    let wing = SKShapeNode(ellipseOf: CGSize(width: 20, height: 12))
    wing.fillColor = SKColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 0.9)
    wing.strokeColor = .lightGray
    wing.lineWidth = 0.5
    wing.position = CGPoint(x: -2, y: 14)
    wing.name = "wing"
    container.addChild(wing)
    addWingAnimation(to: wing, range: 10, duration: 0.2)
}
```

**Step 2: Build and visually verify**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds. Pegasus shows white body, neck, head with ears, flowing tail, large wings.

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "feat: build detailed pegasus sprite with neck, head, flowing tail"
```

---

### Task 6: Build detailed Winged Turtle sprite

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (the `buildWingedTurtle` method)

**Step 1: Replace placeholder with detailed composite**

```swift
private static func buildWingedTurtle(in container: SKNode) {
    // Shell - green dome (upper half circle via path)
    let shellPath = CGMutablePath()
    shellPath.addArc(center: CGPoint(x: 0, y: 0), radius: 15, startAngle: 0, endAngle: .pi, clockwise: false)
    shellPath.closeSubpath()
    let shell = SKShapeNode(path: shellPath)
    shell.fillColor = SKColor(red: 0.0, green: 0.6, blue: 0.2, alpha: 1)
    shell.strokeColor = SKColor(red: 0.0, green: 0.4, blue: 0.1, alpha: 1)
    shell.lineWidth = 1.5
    container.addChild(shell)

    // Shell pattern - darker green lines
    for i in 0..<3 {
        let line = SKShapeNode(rectOf: CGSize(width: 2, height: 10), cornerRadius: 1)
        line.fillColor = SKColor(red: 0.0, green: 0.45, blue: 0.15, alpha: 0.6)
        line.strokeColor = .clear
        line.position = CGPoint(x: CGFloat(i - 1) * 8, y: 5)
        container.addChild(line)
    }

    // Under-body - flat bottom (lighter green rectangle)
    let underBody = SKShapeNode(rectOf: CGSize(width: 30, height: 6), cornerRadius: 2)
    underBody.fillColor = SKColor(red: 0.6, green: 0.8, blue: 0.4, alpha: 1)
    underBody.strokeColor = SKColor(red: 0.0, green: 0.4, blue: 0.1, alpha: 1)
    underBody.lineWidth = 1
    underBody.position = CGPoint(x: 0, y: -3)
    container.addChild(underBody)

    // Head poking out right
    let head = SKShapeNode(circleOfRadius: 6)
    head.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
    head.strokeColor = SKColor(red: 0.0, green: 0.4, blue: 0.1, alpha: 1)
    head.lineWidth = 1
    head.position = CGPoint(x: 16, y: 0)
    container.addChild(head)

    // Eyes
    let eye = SKShapeNode(circleOfRadius: 2)
    eye.fillColor = .white
    eye.strokeColor = .darkGray
    eye.lineWidth = 0.5
    eye.position = CGPoint(x: 19, y: 2)
    container.addChild(eye)

    let pupil = SKShapeNode(circleOfRadius: 1)
    pupil.fillColor = .black
    pupil.strokeColor = .clear
    pupil.position = CGPoint(x: 20, y: 2)
    container.addChild(pupil)

    // Stubby legs
    for (dx, dy) in [(-8, -8), (8, -8)] as [(CGFloat, CGFloat)] {
        let leg = SKShapeNode(ellipseOf: CGSize(width: 6, height: 4))
        leg.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
        leg.strokeColor = SKColor(red: 0.0, green: 0.4, blue: 0.1, alpha: 1)
        leg.lineWidth = 0.5
        leg.position = CGPoint(x: dx, y: dy)
        container.addChild(leg)
    }

    // Tiny tail
    let tail = SKShapeNode(ellipseOf: CGSize(width: 5, height: 3))
    tail.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
    tail.strokeColor = .clear
    tail.position = CGPoint(x: -16, y: -2)
    container.addChild(tail)

    // Absurdly small wings - flapping frantically
    let wing = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
    wing.fillColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 0.8)
    wing.strokeColor = SKColor(red: 0.0, green: 0.4, blue: 0.1, alpha: 1)
    wing.lineWidth = 0.5
    wing.position = CGPoint(x: -4, y: 12)
    wing.name = "wing"
    container.addChild(wing)
    addWingAnimation(to: wing, range: 5, duration: 0.08)
}
```

**Step 2: Build and visually verify**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds. Turtle shows dome shell, head, stubby legs, tiny frantically flapping wings.

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "feat: build detailed winged turtle sprite with shell, legs, tiny wings"
```

---

### Task 7: Build detailed Bat sprite

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (the `buildBat` method)

**Step 1: Replace placeholder with detailed composite**

```swift
private static func buildBat(in container: SKNode) {
    // Body - dark grey inverted triangle / downward oval
    let body = SKShapeNode(ellipseOf: CGSize(width: 16, height: 20))
    body.fillColor = .darkGray
    body.strokeColor = .black
    body.lineWidth = 1.5
    container.addChild(body)

    // Belly - slightly lighter
    let belly = SKShapeNode(ellipseOf: CGSize(width: 10, height: 12))
    belly.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    belly.strokeColor = .clear
    belly.position = CGPoint(x: 0, y: -2)
    container.addChild(belly)

    // Large pointed ears
    for dx in [-5, 5] as [CGFloat] {
        let earPath = CGMutablePath()
        earPath.move(to: CGPoint(x: dx - 3, y: 8))
        earPath.addLine(to: CGPoint(x: dx, y: 18))
        earPath.addLine(to: CGPoint(x: dx + 3, y: 8))
        earPath.closeSubpath()
        let ear = SKShapeNode(path: earPath)
        ear.fillColor = .darkGray
        ear.strokeColor = .black
        ear.lineWidth = 1
        container.addChild(ear)

        // Inner ear - pinkish
        let innerEarPath = CGMutablePath()
        innerEarPath.move(to: CGPoint(x: dx - 1.5, y: 10))
        innerEarPath.addLine(to: CGPoint(x: dx, y: 16))
        innerEarPath.addLine(to: CGPoint(x: dx + 1.5, y: 10))
        innerEarPath.closeSubpath()
        let innerEar = SKShapeNode(path: innerEarPath)
        innerEar.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.4, alpha: 1)
        innerEar.strokeColor = .clear
        container.addChild(innerEar)
    }

    // Tiny eyes - reddish
    for dx in [-4, 4] as [CGFloat] {
        let eye = SKShapeNode(circleOfRadius: 1.5)
        eye.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: dx, y: 4)
        container.addChild(eye)
    }

    // Small fangs
    for dx in [-2, 2] as [CGFloat] {
        let fangPath = CGMutablePath()
        fangPath.move(to: CGPoint(x: dx - 1, y: 0))
        fangPath.addLine(to: CGPoint(x: dx, y: -4))
        fangPath.addLine(to: CGPoint(x: dx + 1, y: 0))
        fangPath.closeSubpath()
        let fang = SKShapeNode(path: fangPath)
        fang.fillColor = .white
        fang.strokeColor = .clear
        container.addChild(fang)
    }

    // Large angular membrane wings (triangular)
    let wingPath = CGMutablePath()
    wingPath.move(to: CGPoint(x: -6, y: 6))
    wingPath.addLine(to: CGPoint(x: -22, y: 10))
    wingPath.addLine(to: CGPoint(x: -18, y: -2))
    wingPath.addLine(to: CGPoint(x: -6, y: -4))
    wingPath.closeSubpath()
    let wing = SKShapeNode(path: wingPath)
    wing.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.85)
    wing.strokeColor = .black
    wing.lineWidth = 0.5
    wing.name = "wing"
    container.addChild(wing)

    // Right wing (mirrored, decorative - no animation)
    let rightWingPath = CGMutablePath()
    rightWingPath.move(to: CGPoint(x: 6, y: 6))
    rightWingPath.addLine(to: CGPoint(x: 22, y: 10))
    rightWingPath.addLine(to: CGPoint(x: 18, y: -2))
    rightWingPath.addLine(to: CGPoint(x: 6, y: -4))
    rightWingPath.closeSubpath()
    let rightWing = SKShapeNode(path: rightWingPath)
    rightWing.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.85)
    rightWing.strokeColor = .black
    rightWing.lineWidth = 0.5
    container.addChild(rightWing)

    addWingAnimation(to: wing, range: 8, duration: 0.18)
}
```

**Step 2: Build and visually verify**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds. Bat shows dark body, large pointed ears with pink inner, red eyes, fangs, angular wings.

**Step 3: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift
git commit -m "feat: build detailed bat sprite with ears, fangs, angular membrane wings"
```

---

### Task 8: Add renderToImage and update character selection screen

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (add `renderToImage`)
- Modify: `FlappyBird/Models/GameCharacter.swift` (remove `sfSymbolName`)
- Modify: `FlappyBird/Views/CharacterSelectionView.swift` (use rendered images)

**Step 1: Add renderToImage to CharacterRenderer**

Add this method to `CharacterRenderer`:

```swift
#if os(iOS)
typealias PlatformImage = UIImage
#elseif os(macOS)
typealias PlatformImage = NSImage
#endif

static func renderToImage(for character: GameCharacter, size: CGSize = CGSize(width: 80, height: 80)) -> PlatformImage? {
    let scene = SKScene(size: size)
    scene.backgroundColor = .clear

    let node = createNode(for: character)
    node.position = CGPoint(x: size.width / 2, y: size.height / 2)
    scene.addChild(node)

    let view = SKView(frame: CGRect(origin: .zero, size: size))
    guard let texture = view.texture(from: scene) else { return nil }

    #if os(iOS)
    return UIImage(cgImage: texture.cgImage())
    #elseif os(macOS)
    let cgImage = texture.cgImage()
    return NSImage(cgImage: cgImage, size: size)
    #endif
}
```

**Step 2: Remove sfSymbolName from GameCharacter**

In `GameCharacter.swift`, delete the entire `sfSymbolName` computed property (lines 36-45).

**Step 3: Update CharacterSelectionView to use rendered images**

Replace the `characterCard` method's `Image(systemName:)` with:

```swift
private func characterCard(character: GameCharacter, isSelected: Bool) -> some View {
    VStack(spacing: 6) {
        Group {
            if let image = CharacterRenderer.renderToImage(for: character, size: CGSize(width: 60, height: 60)) {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 60, height: 60)
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 60, height: 60)
                #endif
            } else {
                // Fallback
                Rectangle()
                    .fill(Color(character.color))
                    .frame(width: 60, height: 60)
            }
        }

        Text(character.displayName)
            .font(.caption.bold())
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
    .frame(width: 100, height: 100)
    .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
    )
}
```

**Step 4: Build and verify**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird build`
Expected: Builds with no errors. Character selection screen shows rendered sprite previews instead of SF Symbol icons.

**Step 5: Commit**

```bash
git add FlappyBird/Game/CharacterRenderer.swift FlappyBird/Models/GameCharacter.swift FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: render sprite previews in character selection, remove SF Symbols"
```

---

### Task 9: Final visual polish and cleanup

**Files:**
- Modify: `FlappyBird/Game/CharacterRenderer.swift` (if any adjustments needed after visual testing)

**Step 1: Run the game and test each character**

Launch the game, select each character one by one, and play a few seconds to verify:
- Each animal is visually recognizable
- Wings animate correctly
- Physics bodies still align with visuals
- Death animation (fade + wing stop) still works
- Character selection previews match in-game sprites

**Step 2: Adjust any positions/sizes if needed after visual inspection**

This is a tuning step. After seeing the sprites in-game, tweak positions, sizes, or colors as needed.

**Step 3: Final commit**

```bash
git add -A
git commit -m "polish: tune sprite proportions after visual testing"
```
