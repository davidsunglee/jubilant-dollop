import SpriteKit

// MARK: - Input Handling
extension GameScene {

    func handleJump(forPlayer playerIndex: Int) {
        guard isGameActive else { return }
        guard playerIndex >= 1 && playerIndex <= players.count else { return }
        let player = players[playerIndex - 1]
        guard player.isAlive else { return }
        player.jump(impulse: jumpImpulse)
        AudioManager.shared.playFlapSound(on: self)
    }

    // MARK: - iOS / iPadOS Touch Input
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameActive else { return }

        for touch in touches {
            let location = touch.location(in: self)

            if router.config.playerCount == 1 {
                handleJump(forPlayer: 1)
            } else {
                // 2P: left half = P1, right half = P2
                if location.x < size.width / 2 {
                    handleJump(forPlayer: 1)
                } else {
                    handleJump(forPlayer: 2)
                }
            }
        }
    }
    #endif

    // MARK: - macOS Keyboard Input
    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        guard isGameActive else { return }
        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return }

        if router.config.playerCount == 1 {
            // Space bar for single player
            if chars == " " {
                handleJump(forPlayer: 1)
            }
        } else {
            // 2P: "a" = P1, "l" = P2
            switch chars {
            case "a":
                handleJump(forPlayer: 1)
            case "l":
                handleJump(forPlayer: 2)
            default:
                break
            }
        }
    }
    #endif
}
