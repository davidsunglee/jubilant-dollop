import SwiftUI
import SpriteKit

struct CharacterSelectionView: View {
    @ObservedObject var router: GameRouter
    @State private var player1Selection: GameCharacter = .avian
    @State private var player2Selection: GameCharacter = .bat
    @State private var headerVisible = false
    @State private var cardsVisible = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact2P: Bool {
        horizontalSizeClass == .compact && router.config.playerCount == 2
    }

    var body: some View {
        ZStack {
            MenuBackgroundView(tint: .cool)

            VStack(spacing: isCompact2P ? 6 : 20) {
                Text("Select Character\(router.config.playerCount == 2 ? "s" : "")")
                    .font(.system(size: isCompact2P ? 28 : 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .offset(y: headerVisible ? 0 : -15)
                    .opacity(headerVisible ? 1 : 0)

                if router.config.playerCount == 2 {
                    HStack(spacing: 30) {
                        characterPicker(title: "Player 1", selection: $player1Selection, compact: isCompact2P)
                        Divider().frame(height: 300)
                        characterPicker(title: "Player 2", selection: $player2Selection, compact: isCompact2P)
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
                        .font(isCompact2P ? .headline.bold() : .title2.bold())
                        .frame(height: isCompact2P ? 44 : 50)
                }
                .buttonStyle(GlassButtonStyle(accentColor: .green))
                .opacity(cardsVisible ? 1 : 0)
            }
            .padding()
            .safeAreaPadding()
            .padding(.top, isCompact2P ? 52 : 0)
            .padding(.bottom, isCompact2P ? 24 : 0)

            // Back button
            VStack {
                HStack {
                    BackButton { router.goBackToTitle() }
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .safeAreaPadding(.top)
            .padding(.top, isCompact2P ? 52 : 0)
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

    private func characterPicker(title: String, selection: Binding<GameCharacter>, compact: Bool = false) -> some View {
        VStack(spacing: compact ? 8 : 12) {
            Text(title)
                .font(compact ? .footnote.bold() : .title3.bold())

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(GameCharacter.allCases) { character in
                    characterCard(character: character, isSelected: selection.wrappedValue == character, size: compact ? 84 : 100, compact: compact)
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

    private func characterCard(character: GameCharacter, isSelected: Bool, size: CGFloat = 100, compact: Bool = false) -> some View {
        VStack(spacing: compact ? 2 : 6) {
            LiveCharacterPreview(character: character, isSelected: isSelected)
                .offset(y: compact ? 4 : 0)

            Text(character.displayName)
                .font(compact ? .system(size: 9, weight: .bold) : .caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size, height: size)
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
