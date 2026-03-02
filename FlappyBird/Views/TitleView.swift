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
