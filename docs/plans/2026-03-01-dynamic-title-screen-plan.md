# Dynamic Title Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the static gradient title screen background with a live, parallax-scrolling random environment.

**Architecture:** Create a new `TitleBackgroundScene` (SKScene) that picks a random environment and renders its scrolling background using the existing `EnvironmentRenderer` and `ParallaxBackground` systems. Wrap it in a scene holder to prevent SwiftUI recreation. Swap it into `TitleView` behind a dark scrim overlay.

**Tech Stack:** Swift, SwiftUI, SpriteKit

**Design doc:** `docs/plans/2026-03-01-dynamic-title-screen-design.md`

---

### Task 1: Create `TitleBackgroundScene`

**Files:**
- Create: `FlappyBird/Views/TitleBackgroundScene.swift`

**Context:** This scene is modeled directly on the existing `EnvironmentPreviewScene` in `FlappyBird/Views/LiveEnvironmentPreview.swift:4-49`. The key differences: it picks a random environment instead of receiving one, runs at 30 FPS instead of 15, and uses a proportional ground height instead of a fixed 8pt (since it renders full-screen).

**Step 1: Create the scene file**

```swift
import SpriteKit

class TitleBackgroundScene: SKScene {
    private var parallax: ParallaxBackground?
    private var lastUpdateTime: TimeInterval = 0

    override init(size: CGSize) {
        super.init(size: size)
        let environment = GameEnvironment.allCases.randomElement()!
        backgroundColor = environment.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        view.preferredFramesPerSecond = 30

        let environment = GameEnvironment.allCases.randomElement()!
        backgroundColor = environment.backgroundColor

        let parallax = ParallaxBackground(baseSpeed: 20)
        let renderer = environment.renderer
        renderer.buildPreviewBackground(scene: self, size: size, parallax: parallax)

        let groundHeight: CGFloat = size.height * 0.08
        let groundSize = CGSize(width: size.width, height: groundHeight)
        var groundNodes: [SKNode] = []
        for i in 0..<2 {
            let tile = renderer.buildGroundTile(size: groundSize)
            tile.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
            tile.zPosition = -2
            addChild(tile)
            groundNodes.append(tile)
        }
        parallax.addLayer(nodes: groundNodes, speedMultiplier: 1.0, width: size.width)

        self.parallax = parallax
    }

    override func update(_ currentTime: TimeInterval) {
        guard isPaused == false else { return }
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 30.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        parallax?.update(deltaTime: min(deltaTime, 0.1))
    }
}
```

**Notes:**
- The environment is chosen in `didMove(to:)` rather than `init` so it picks fresh each time the scene is presented. The `init` also sets a random background color so there's no flash of default gray before `didMove` fires.
- Ground height is `size.height * 0.08` (proportional) instead of the hardcoded `8pt` used in the 100pt-tall preview scenes. At full screen this gives a reasonable ground strip.
- Default delta time uses `1.0 / 30.0` to match the 30 FPS target (the preview scene uses `1.0 / 15.0`).

**Step 2: Build and verify it compiles**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
git add FlappyBird/Views/TitleBackgroundScene.swift
git commit -m "feat: add TitleBackgroundScene with random environment parallax"
```

---

### Task 2: Create `TitleBackgroundSceneHolder`

**Files:**
- Modify: `FlappyBird/Views/TitleBackgroundScene.swift` (append to bottom)

**Context:** This follows the exact same pattern as `EnvironmentPreviewSceneHolder` in `FlappyBird/Views/LiveEnvironmentPreview.swift:52-63`. It prevents SwiftUI from recreating the SKScene on every body evaluation.

**Step 1: Append the holder class to the scene file**

Add to the bottom of `FlappyBird/Views/TitleBackgroundScene.swift`:

```swift

class TitleBackgroundSceneHolder: ObservableObject {
    let scene: TitleBackgroundScene

    init() {
        let scene = TitleBackgroundScene(size: CGSize(width: 400, height: 800))
        scene.scaleMode = .resizeFill
        self.scene = scene
    }
}
```

**Notes:**
- The initial size (400x800) is arbitrary because `.resizeFill` will scale to the actual view frame. It just needs a reasonable aspect ratio.
- No environment parameter needed — the scene picks randomly internally.

**Step 2: Build and verify it compiles**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
git add FlappyBird/Views/TitleBackgroundScene.swift
git commit -m "feat: add TitleBackgroundSceneHolder to prevent SwiftUI recreation"
```

---

### Task 3: Update `TitleView` to use the live background

**Files:**
- Modify: `FlappyBird/Views/TitleView.swift:1-52`

**Context:** Replace the `MenuBackgroundView(tint: .neutral)` on line 10 with a `SpriteView` hosting the title scene, plus a dark scrim for readability. Everything else (title text, buttons, animations) stays exactly the same.

**Step 1: Update `TitleView.swift`**

Replace the entire file contents with:

```swift
import SwiftUI
import SpriteKit

struct TitleView: View {
    @ObservedObject var router: GameRouter
    @StateObject private var sceneHolder = TitleBackgroundSceneHolder()
    @State private var titleVisible = false
    @State private var buttonsVisible = false

    var body: some View {
        ZStack {
            SpriteView(scene: sceneHolder.scene)
                .ignoresSafeArea()
                .transaction { $0.animation = nil }

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Flappy Bird")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    .offset(y: titleVisible ? 0 : 20)
                    .opacity(titleVisible ? 1 : 0)

                VStack(spacing: 20) {
                    Button {
                        router.selectPlayerCount(1)
                    } label: {
                        Text("1 Player")
                    }
                    .buttonStyle(GlassButtonStyle(accentColor: .green))

                    Button {
                        router.selectPlayerCount(2)
                    } label: {
                        Text("2 Players")
                    }
                    .buttonStyle(GlassButtonStyle(accentColor: .orange))
                }
                .opacity(buttonsVisible ? 1 : 0)
            }
        }
        .onAppear {
            AudioManager.shared.playMenuMusic(forState: .title)
            sceneHolder.scene.isPaused = false
            withAnimation(.easeOut(duration: 0.6)) {
                titleVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                buttonsVisible = true
            }
        }
        .onDisappear {
            titleVisible = false
            buttonsVisible = false
            sceneHolder.scene.isPaused = true
        }
    }
}
```

**Key changes from the original (`TitleView.swift:1-52`):**
- Line 2: Added `import SpriteKit`
- Line 6: Added `@StateObject private var sceneHolder = TitleBackgroundSceneHolder()`
- Lines 10-14: Replaced `MenuBackgroundView(tint: .neutral)` with `SpriteView(scene: sceneHolder.scene)` + `.ignoresSafeArea()` + `.transaction { $0.animation = nil }` (transaction prevents SwiftUI from animating the SpriteKit view itself)
- Lines 17-18: Added `Color.black.opacity(0.25).ignoresSafeArea()` scrim overlay
- Line 24: Bumped shadow opacity from `0.2` to `0.3` for better readability against vivid backgrounds
- Line 51: Added `sceneHolder.scene.isPaused = false` in `onAppear`
- Line 57: Added `sceneHolder.scene.isPaused = true` in `onDisappear`

**Step 2: Build and verify it compiles**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: `BUILD SUCCEEDED`

**Step 3: Run the app and visually verify**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' && open -a FlappyBird` or launch from Xcode.

Verify:
- Title screen shows a random environment scrolling in the background
- Background has parallax layers moving at different speeds
- Environment-specific animated elements are visible (e.g. snowflakes for Arctic, bubbles for Underwater)
- Ground tiles scroll at the bottom
- Title text "Flappy Bird" is readable over the scrim
- Glass buttons pick up environment colors through their material blur
- Navigating away and back shows a different random environment
- No layout warnings or constraint issues in the console

**Step 4: Commit**

```bash
git add FlappyBird/Views/TitleView.swift
git commit -m "feat: replace static title background with live environment scene"
```

---

### Task 4: Final visual polish pass

**Files:**
- Possibly modify: `FlappyBird/Views/TitleBackgroundScene.swift`
- Possibly modify: `FlappyBird/Views/TitleView.swift`

**Step 1: Test all 6 environments as title backgrounds**

Temporarily change the random selection to cycle through each environment and verify they all look good as full-screen backgrounds:
- **Classic**: Sky blue with hills, clouds, birds — should feel cheerful
- **Jungle**: Green with canopy, vines, fireflies — should feel lush
- **Underwater**: Deep navy with seaweed, light rays, bubbles — should feel immersive
- **Arctic**: Pale blue with mountains, snow drifts, snowflakes — should feel crisp
- **Desert**: Yellow with dunes, cacti, heat shimmer — should feel warm
- **Space**: Black with nebulae, twinkling stars, shooting star — should feel vast

**Step 2: Verify cross-platform rendering**

Test on both macOS (800x600 window) and iOS simulator to confirm:
- Scene fills the screen correctly with `.resizeFill`
- Ground height proportion looks right on both form factors
- No clipping or misalignment

**Step 3: Adjust if needed**

If any environment looks too bright/dark behind the scrim, or the ground height needs tweaking, adjust the scrim opacity (`0.25`) or ground height multiplier (`0.08`) in the relevant files.

**Step 4: Commit any polish changes**

```bash
git add -A
git commit -m "fix: polish title background rendering across environments"
```

(Skip this commit if no changes were needed.)
