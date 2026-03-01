import SwiftUI

struct TitleView: View {
    @ObservedObject var router: GameRouter

    var body: some View {
        ZStack {
            Color.cyan.ignoresSafeArea()

            VStack(spacing: 40) {

                Text("Flappy Bird")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                VStack(spacing: 20) {
                    Button {
                        router.selectPlayerCount(1)
                    } label: {
                        Text("1 Player")
                            .font(.title2.bold())
                            .frame(width: 200, height: 50)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        router.selectPlayerCount(2)
                    } label: {
                        Text("2 Players")
                            .font(.title2.bold())
                            .frame(width: 200, height: 50)
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            AudioManager.shared.playMenuMusic(forState: .title)
        }
    }
}
