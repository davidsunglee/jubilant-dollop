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
        .animation(.easeOut(duration: 0.4), value: router.state)
    }
}
