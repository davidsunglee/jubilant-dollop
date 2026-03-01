import SwiftUI

struct EnvironmentSelectionView: View {
    @ObservedObject var router: GameRouter

    var body: some View {
        ZStack {
            Color.cyan.opacity(0.3).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Select Environment")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(GameEnvironment.allCases) { environment in
                        environmentCard(environment: environment)
                            .onTapGesture {
                                router.selectEnvironment(environment)
                            }
                    }
                }
                .frame(maxWidth: 600)
                .padding()
            }
        }
    }

    private func environmentCard(environment: GameEnvironment) -> some View {
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
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
