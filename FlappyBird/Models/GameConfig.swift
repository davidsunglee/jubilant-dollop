import Foundation

struct GameConfig {
    var playerCount: Int = 1
    var player1Character: GameCharacter = .avian
    var player2Character: GameCharacter = .bat
    var environment: GameEnvironment = .classic
}
