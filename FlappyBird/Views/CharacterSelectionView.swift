import SwiftUI

struct CharacterSelectionView: View {
    @ObservedObject var router: GameRouter
    @State private var player1Selection: GameCharacter = .avian
    @State private var player2Selection: GameCharacter = .bat

    var body: some View {
        ZStack {
            Color.cyan.opacity(0.3).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Select Character\(router.config.playerCount == 2 ? "s" : "")")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                if router.config.playerCount == 2 {
                    HStack(spacing: 30) {
                        characterPicker(title: "Player 1", selection: $player1Selection)
                        Divider().frame(height: 300)
                        characterPicker(title: "Player 2", selection: $player2Selection)
                    }
                } else {
                    characterPicker(title: "Player 1", selection: $player1Selection)
                }

                Button {
                    router.selectCharacter(player1Selection, forPlayer: 1)
                    if router.config.playerCount == 2 {
                        router.selectCharacter(player2Selection, forPlayer: 2)
                    }
                    router.confirmCharacterSelection()
                } label: {
                    Text("Continue")
                        .font(.title2.bold())
                        .frame(width: 200, height: 50)
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .onAppear {
            AudioManager.shared.playMenuMusic(forState: .characterSelection)
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
                            selection.wrappedValue = character
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
}
