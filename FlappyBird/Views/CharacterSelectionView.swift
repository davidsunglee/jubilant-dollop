import SwiftUI
import SpriteKit

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
            LiveCharacterPreview(character: character, isSelected: isSelected)

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
