import SwiftUI
import SpriteKit

struct GameplayView: View {
    @ObservedObject var router: GameRouter
    @State private var scene: GameScene?

    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }

            // Score overlay
            if router.state == .playing {
                scoreOverlay
            }

            // Game over overlay
            if router.state == .gameOver {
                gameOverOverlay
            }
        }
        .onAppear {
            createScene()
        }
        .onChange(of: router.state) { _, newState in
            if newState == .playing {
                createScene()
            }
        }
    }

    private var scoreOverlay: some View {
        VStack {
            HStack {
                if router.config.playerCount == 2 {
                    Text("P1: \(router.scores[0])")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                    Spacer()
                    Text("P2: \(router.scores[1])")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                } else {
                    Text("\(router.scores[0])")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            Spacer()
        }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Game Over")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if router.config.playerCount == 2 {
                    HStack(spacing: 40) {
                        VStack {
                            Text("Player 1")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("\(router.scores[0])")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        VStack {
                            Text("Player 2")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("\(router.scores[1])")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                } else {
                    Text("Score: \(router.scores[0])")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 20) {
                    Button {
                        router.restart()
                    } label: {
                        Text("Retry")
                            .font(.title2.bold())
                            .frame(width: 150, height: 50)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        router.returnToTitle()
                    } label: {
                        Text("Menu")
                            .font(.title2.bold())
                            .frame(width: 150, height: 50)
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func createScene() {
        let newScene = GameScene(router: router)
        newScene.scaleMode = .resizeFill
        scene = newScene
    }
}
