import SwiftUI

struct ContentView: View {
    @StateObject private var router = GameRouter()

    var body: some View {
        ZStack {
            switch router.state {
            case .title:
                TitleView(router: router)
            case .characterSelection:
                CharacterSelectionView(router: router)
            case .environmentSelection:
                EnvironmentSelectionView(router: router)
            case .playing:
                GameplayView(router: router)
            case .gameOver:
                GameplayView(router: router)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.state)
    }
}
