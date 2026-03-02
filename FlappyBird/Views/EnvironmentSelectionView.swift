import SwiftUI

struct EnvironmentSelectionView: View {
    @ObservedObject var router: GameRouter
    @State private var tappedEnvironment: GameEnvironment? = nil
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
                        environmentCard(environment: environment, isSelected: tappedEnvironment == environment)
                            .onTapGesture {
                                guard tappedEnvironment == nil else { return }
                                tappedEnvironment = environment
                                router.selectEnvironment(environment)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    router.startGame()
                                }
                            }
                    }
                }
                .frame(maxWidth: 750)
                .padding(.horizontal)
                .opacity(cardsVisible ? 1 : 0)
            }
            .padding(.vertical)

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
            tappedEnvironment = nil
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
            LiveEnvironmentPreview(environment: environment)

            Text(environment.displayName)
                .font(.headline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 12)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
