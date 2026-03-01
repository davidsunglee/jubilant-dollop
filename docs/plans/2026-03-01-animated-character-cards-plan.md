# Animated Character Selection Cards Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace static character images with live animated SpriteKit previews showing wing flapping and bobbing in the character selection screen.

**Architecture:** A new `LiveCharacterPreview` SwiftUI view embeds a `SpriteView` per card. Each hosts a small `SKScene` using the existing `CharacterRenderer.createNode()` for wing animations, plus a bobbing `SKAction`. Selected cards get enhanced bobbing amplitude.

**Tech Stack:** SwiftUI, SpriteKit (`SpriteView`, `SKScene`, `SKAction`), existing `CharacterRenderer`

---

### Task 1: Create LiveCharacterPreview

**Files:**
- Create: `FlappyBird/Views/LiveCharacterPreview.swift`

**Step 1: Create the SKScene subclass and SwiftUI view**

Create `FlappyBird/Views/LiveCharacterPreview.swift` with this content:

```swift
import SwiftUI
import SpriteKit

class CharacterPreviewScene: SKScene {
    private let character: GameCharacter
    private let isSelected: Bool
    private var characterNode: SKNode?

    init(character: GameCharacter, isSelected: Bool, size: CGSize) {
        self.character = character
        self.isSelected = isSelected
        super.init(size: size)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()

        let node = CharacterRenderer.createNode(for: character)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(node)
        characterNode = node

        let amplitude: CGFloat = isSelected ? 7 : 4
        let bobUp = SKAction.moveBy(x: 0, y: amplitude, duration: 0.375)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SKAction.moveBy(x: 0, y: -amplitude, duration: 0.375)
        bobDown.timingMode = .easeInEaseOut
        let bob = SKAction.sequence([bobUp, bobDown])
        node.run(SKAction.repeatForever(bob))
    }
}

struct LiveCharacterPreview: View {
    let character: GameCharacter
    let isSelected: Bool

    private var scene: CharacterPreviewScene {
        let scene = CharacterPreviewScene(
            character: character,
            isSelected: isSelected,
            size: CGSize(width: 60, height: 60)
        )
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: 60, height: 60)
    }
}
```

**Step 2: Add file to Xcode project**

The new file must be registered in `FlappyBird.xcodeproj/project.pbxproj`. Add it to:
- `PBXBuildFile` section (two entries — one per target: iOS and macOS)
- `PBXFileReference` section
- `PBXGroup` for the Views folder (alongside `CharacterSelectionView.swift`)
- Both `PBXSourcesBuildPhase` sections

Use unique 24-character hex IDs that don't collide with existing entries.

**Step 3: Verify it builds**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme "FlappyBird (iOS)" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -5`
Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit**

```bash
git add FlappyBird/Views/LiveCharacterPreview.swift FlappyBird.xcodeproj/project.pbxproj
git commit -m "feat: add LiveCharacterPreview with animated SpriteKit scenes"
```

---

### Task 2: Integrate LiveCharacterPreview into CharacterSelectionView

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift:1,96-115`

**Step 1: Add SpriteKit import**

Add `import SpriteKit` after the existing `import SwiftUI` on line 1.

**Step 2: Replace static image rendering with LiveCharacterPreview**

In `characterCard()`, replace the `Group` block (lines 97-115) with:

```swift
            LiveCharacterPreview(character: character, isSelected: isSelected)
```

This replaces the entire `Group` containing the `renderToImage` call, platform-specific `Image` views, and the fallback `Rectangle`.

**Step 3: Verify it builds**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme "FlappyBird (iOS)" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -5`
Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: use live animated character previews in selection cards"
```

---

### Task 3: Visual verification

**Step 1: Run the app in simulator**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme "FlappyBird (iOS)" -destination "platform=iOS Simulator,name=iPhone 16" build`

Launch in simulator and navigate to character selection screen.

**Step 2: Verify checklist**

- [ ] All 6 character cards show animated characters (wings flapping)
- [ ] Characters bob gently up and down within their cards
- [ ] Selected card has more pronounced bobbing
- [ ] Card backgrounds (material) show through transparent scene
- [ ] Tapping a card selects it with spring animation
- [ ] Continue button navigates to environment selection
- [ ] Back button returns to title screen
- [ ] 2-player mode shows 12 animated cards without performance issues
