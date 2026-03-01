# UI Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Polish the title, character select, and environment select screens with gradient backgrounds, glass-morphism cards/buttons, subtle animations, and back navigation.

**Architecture:** Create a shared `MenuBackgroundView` SwiftUI component used by all three menu screens. Restyle buttons and cards with `.ultraThinMaterial` glass-morphism. Add entrance animations. Add `goBack()` to `GameRouter` and wire back buttons into character/environment select screens. Change environment select to select-then-start instead of tap-to-start.

**Tech Stack:** SwiftUI (no SpriteKit changes), targeting macOS + iOS

---

### Task 1: Create MenuBackgroundView

**Files:**
- Create: `FlappyBird/Views/MenuBackgroundView.swift`

**Step 1: Create the MenuBackgroundView component**

```swift
import SwiftUI

struct FloatingCloud: View {
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let xOffset: CGFloat
    let yOffset: CGFloat

    @State private var animate = false

    var body: some View {
        Ellipse()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size * 0.6)
            .blur(radius: size * 0.15)
            .offset(
                x: animate ? xOffset : -xOffset,
                y: animate ? yOffset : -yOffset
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    animate = true
                }
            }
    }
}

enum MenuScreenTint {
    case neutral    // title
    case cool       // character select
    case warm       // environment select

    var topColor: Color {
        switch self {
        case .neutral: return Color(red: 0.55, green: 0.78, blue: 0.95)
        case .cool:    return Color(red: 0.50, green: 0.75, blue: 0.98)
        case .warm:    return Color(red: 0.60, green: 0.78, blue: 0.92)
        }
    }

    var midColor: Color {
        switch self {
        case .neutral: return Color(red: 0.85, green: 0.92, blue: 0.98)
        case .cool:    return Color(red: 0.82, green: 0.90, blue: 1.00)
        case .warm:    return Color(red: 0.88, green: 0.92, blue: 0.95)
        }
    }

    var bottomColor: Color {
        switch self {
        case .neutral: return Color(red: 0.98, green: 0.90, blue: 0.85)
        case .cool:    return Color(red: 0.92, green: 0.90, blue: 0.92)
        case .warm:    return Color(red: 1.00, green: 0.92, blue: 0.85)
        }
    }
}

struct MenuBackgroundView: View {
    var tint: MenuScreenTint = .neutral

    private let clouds: [(size: CGFloat, opacity: Double, duration: Double, xOffset: CGFloat, yOffset: CGFloat)] = [
        (120, 0.15, 12, 40, 15),
        (80, 0.12, 10, -30, 20),
        (100, 0.18, 14, 50, -10),
        (60, 0.10, 9, -20, 25),
        (90, 0.14, 11, 35, -18),
        (70, 0.16, 13, -45, 12),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [tint.topColor, tint.midColor, tint.bottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(Array(clouds.enumerated()), id: \.offset) { index, cloud in
                    FloatingCloud(
                        size: cloud.size,
                        opacity: cloud.opacity,
                        duration: cloud.duration,
                        xOffset: cloud.xOffset,
                        yOffset: cloud.yOffset
                    )
                    .position(
                        x: geo.size.width * [0.15, 0.75, 0.5, 0.85, 0.3, 0.65][index],
                        y: geo.size.height * [0.2, 0.35, 0.55, 0.15, 0.7, 0.45][index]
                    )
                }
            }
            .ignoresSafeArea()
        }
    }
}
```

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Views/MenuBackgroundView.swift
git commit -m "feat: add MenuBackgroundView with gradient and floating clouds"
```

---

### Task 2: Create GlassButtonStyle

**Files:**
- Create: `FlappyBird/Views/GlassButtonStyle.swift`

**Step 1: Create the glass button style and back button component**

```swift
import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    var accentColor: Color = .green

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundStyle(accentColor)
            .frame(width: 200, height: 50)
            .background(.ultraThinMaterial)
            .overlay(Color.white.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct BackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.headline.bold())
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
```

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Views/GlassButtonStyle.swift
git commit -m "feat: add GlassButtonStyle and BackButton components"
```

---

### Task 3: Add back navigation to GameRouter

**Files:**
- Modify: `FlappyBird/ViewModels/GameRouter.swift`

**Step 1: Add goBack methods to GameRouter**

After the existing `selectPlayerCount` method (line 16), add:

```swift
    func goBackToTitle() {
        state = .title
    }

    func goBackToCharacterSelection() {
        state = .characterSelection
    }
```

Also modify `selectEnvironment` to decouple selection from starting the game. Change lines 30-33 from:

```swift
    func selectEnvironment(_ environment: GameEnvironment) {
        config.environment = environment
        startGame()
    }
```

to:

```swift
    func selectEnvironment(_ environment: GameEnvironment) {
        config.environment = environment
    }
```

The `startGame()` call will now be triggered by the new "Start" button in `EnvironmentSelectionView`.

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/ViewModels/GameRouter.swift
git commit -m "feat: add back navigation and decouple environment selection from game start"
```

---

### Task 4: Polish TitleView

**Files:**
- Modify: `FlappyBird/Views/TitleView.swift`

**Step 1: Replace TitleView with polished version**

Replace the entire contents of `TitleView.swift` with:

```swift
import SwiftUI

struct TitleView: View {
    @ObservedObject var router: GameRouter
    @State private var titleVisible = false
    @State private var buttonsVisible = false

    var body: some View {
        ZStack {
            MenuBackgroundView(tint: .neutral)

            VStack(spacing: 40) {
                Text("Flappy Bird")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
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
        }
    }
}
```

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Views/TitleView.swift
git commit -m "feat: polish TitleView with gradient background, glass buttons, entrance animations"
```

---

### Task 5: Polish CharacterSelectionView

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift`

**Step 1: Replace CharacterSelectionView with polished version**

Replace the entire contents of `CharacterSelectionView.swift` with:

```swift
import SwiftUI

struct CharacterSelectionView: View {
    @ObservedObject var router: GameRouter
    @State private var player1Selection: GameCharacter = .avian
    @State private var player2Selection: GameCharacter = .bat
    @State private var headerVisible = false
    @State private var cardsVisible = false

    var body: some View {
        ZStack {
            MenuBackgroundView(tint: .cool)

            VStack(spacing: 20) {
                Text("Select Character\(router.config.playerCount == 2 ? "s" : "")")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .offset(y: headerVisible ? 0 : -15)
                    .opacity(headerVisible ? 1 : 0)

                if router.config.playerCount == 2 {
                    HStack(spacing: 30) {
                        characterPicker(title: "Player 1", selection: $player1Selection)
                        Divider().frame(height: 300)
                        characterPicker(title: "Player 2", selection: $player2Selection)
                    }
                    .opacity(cardsVisible ? 1 : 0)
                } else {
                    characterPicker(title: "Player 1", selection: $player1Selection)
                        .opacity(cardsVisible ? 1 : 0)
                }

                Button {
                    router.selectCharacter(player1Selection, forPlayer: 1)
                    if router.config.playerCount == 2 {
                        router.selectCharacter(player2Selection, forPlayer: 2)
                    }
                    router.confirmCharacterSelection()
                } label: {
                    Text("Continue")
                }
                .buttonStyle(GlassButtonStyle(accentColor: .green))
                .opacity(cardsVisible ? 1 : 0)
            }
            .padding()

            // Back button
            VStack {
                HStack {
                    BackButton { router.goBackToTitle() }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .onAppear {
            AudioManager.shared.playMenuMusic(forState: .characterSelection)
            withAnimation(.easeOut(duration: 0.4)) {
                headerVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                cardsVisible = true
            }
        }
        .onDisappear {
            headerVisible = false
            cardsVisible = false
        }
    }

    private func characterPicker(title: String, selection: Binding<GameCharacter>) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(GameCharacter.allCases) { character in
                    characterCard(character: character, isSelected: selection.wrappedValue == character)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selection.wrappedValue = character
                            }
                        }
                }
            }
            .frame(maxWidth: 400)
        }
    }

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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.clear, lineWidth: 0)
        )
        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 12)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}
```

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: polish CharacterSelectionView with glass cards, glow selection, back button"
```

---

### Task 6: Polish EnvironmentSelectionView

**Files:**
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift`

**Step 1: Replace EnvironmentSelectionView with polished version**

Replace the entire contents of `EnvironmentSelectionView.swift` with:

```swift
import SwiftUI

struct EnvironmentSelectionView: View {
    @ObservedObject var router: GameRouter
    @State private var selectedEnvironment: GameEnvironment? = nil
    @State private var headerVisible = false
    @State private var cardsVisible = false

    var body: some View {
        ZStack {
            MenuBackgroundView(tint: .warm)

            VStack(spacing: 20) {
                Text("Select Environment")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .offset(y: headerVisible ? 0 : -15)
                    .opacity(headerVisible ? 1 : 0)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(GameEnvironment.allCases) { environment in
                        environmentCard(environment: environment, isSelected: selectedEnvironment == environment)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedEnvironment = environment
                                    router.selectEnvironment(environment)
                                }
                            }
                    }
                }
                .frame(maxWidth: 600)
                .padding()
                .opacity(cardsVisible ? 1 : 0)

                if selectedEnvironment != nil {
                    Button {
                        router.startGame()
                    } label: {
                        Text("Start")
                    }
                    .buttonStyle(GlassButtonStyle(accentColor: .green))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }

            // Back button
            VStack {
                HStack {
                    BackButton { router.goBackToCharacterSelection() }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .onAppear {
            AudioManager.shared.playMenuMusic(forState: .environmentSelection)
            selectedEnvironment = nil
            withAnimation(.easeOut(duration: 0.4)) {
                headerVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                cardsVisible = true
            }
        }
        .onDisappear {
            headerVisible = false
            cardsVisible = false
        }
    }

    private func environmentCard(environment: GameEnvironment, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            Group {
                if let image = EnvironmentPreviewRenderer.renderToImage(for: environment, size: CGSize(width: 160, height: 80)) {
                    #if os(iOS)
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.high)
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    #elseif os(macOS)
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(.high)
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    #endif
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(environment.backgroundColor))
                        .frame(height: 80)
                }
            }

            Text(environment.displayName)
                .font(.headline)
        }
        .frame(width: 160, height: 130)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 12)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}
```

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Views/EnvironmentSelectionView.swift
git commit -m "feat: polish EnvironmentSelectionView with glass cards, select-then-start, back button"
```

---

### Task 7: Update ContentView transition timing

**Files:**
- Modify: `FlappyBird/Views/ContentView.swift`

**Step 1: Update transition animation**

In `ContentView.swift`, change line 21 from:

```swift
        .animation(.easeInOut(duration: 0.3), value: router.state)
```

to:

```swift
        .animation(.easeOut(duration: 0.4), value: router.state)
```

**Step 2: Verify it builds**

Run: `xcodebuild build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FlappyBird/Views/ContentView.swift
git commit -m "feat: smooth out screen transition to 0.4s easeOut"
```

---

### Task 8: Final build and visual verification

**Step 1: Full clean build**

Run: `xcodebuild clean build -scheme FlappyBird -destination 'platform=macOS' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

**Step 2: Run the app and verify**

Run the app and check:
- Title screen: gradient background with floating clouds, glass buttons, title slides in
- Character select: back button works (goes to title), glass cards with glow selection, continue button
- Environment select: back button works (goes to character select), glass cards, tap selects (doesn't start), Start button appears after selection
- All screens: consistent gradient backgrounds with subtle tint variations

**Step 3: Commit any fixes if needed**
