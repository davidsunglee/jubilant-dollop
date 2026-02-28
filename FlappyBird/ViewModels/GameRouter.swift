import Foundation
import Combine

class GameRouter: ObservableObject {
    @Published var state: GameState = .title
    @Published var config = GameConfig()
    @Published var scores: [Int] = [0, 0]
    @Published var playerAlive: [Bool] = [true, true]

    // MARK: - State Transitions

    func selectPlayerCount(_ count: Int) {
        config.playerCount = count
        state = .characterSelection
    }

    func selectCharacter(_ character: GameCharacter, forPlayer player: Int) {
        if player == 1 {
            config.player1Character = character
        } else {
            config.player2Character = character
        }
    }

    func confirmCharacterSelection() {
        state = .environmentSelection
    }

    func selectEnvironment(_ environment: GameEnvironment) {
        config.environment = environment
        startGame()
    }

    func startGame() {
        scores = [0, 0]
        playerAlive = [true, true]
        state = .playing
    }

    func incrementScore(forPlayer player: Int) {
        guard player >= 1 && player <= 2 else { return }
        scores[player - 1] += 1
    }

    func playerDied(_ player: Int) {
        guard player >= 1 && player <= 2 else { return }
        playerAlive[player - 1] = false

        if config.playerCount == 1 {
            state = .gameOver
        } else if !playerAlive[0] && !playerAlive[1] {
            state = .gameOver
        }
    }

    func returnToTitle() {
        state = .title
    }

    func restart() {
        startGame()
    }
}
