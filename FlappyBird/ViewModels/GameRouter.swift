import Foundation
import Combine

class GameRouter: ObservableObject {
    @Published var state: GameState = .title
    @Published var config = GameConfig()
    @Published var scores: [Int] = [0, 0]
    @Published var playerAlive: [Bool] = [true, true]
    @Published var lives: [Int] = [3, 3]

    // MARK: - State Transitions

    func selectPlayerCount(_ count: Int) {
        config.playerCount = count
        state = .characterSelection
    }

    func goBackToTitle() {
        state = .title
    }

    func goBackToCharacterSelection() {
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
    }

    func startGame() {
        scores = [0, 0]
        playerAlive = [true, true]
        lives = [3, 3]
        state = .playing
    }

    func incrementScore(forPlayer player: Int) {
        guard player >= 1 && player <= 2 else { return }
        let index = player - 1
        let oldScore = scores[index]
        scores[index] += 1
        let newScore = scores[index]
        // Bonus life every 100 points
        if newScore / 100 > oldScore / 100 {
            lives[index] += 1
        }
    }

    /// Returns true if the player survived, false if they died.
    func playerHit(_ player: Int) -> Bool {
        guard player >= 1 && player <= 2 else { return false }
        let index = player - 1
        if lives[index] > 1 {
            lives[index] -= 1
            return true
        } else {
            lives[index] = 0
            playerDied(player)
            return false
        }
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
