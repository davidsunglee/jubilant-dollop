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
