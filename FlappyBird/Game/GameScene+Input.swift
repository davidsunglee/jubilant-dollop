import SpriteKit

// MARK: - Input Handling
extension GameScene {

    func handleJump(forPlayer playerIndex: Int) {
        guard isGameActive else { return }
        guard playerIndex >= 1 && playerIndex <= players.count else { return }
        let player = players[playerIndex - 1]
        guard player.isAlive else { return }
        player.jump(impulse: jumpImpulse)
        AudioManager.shared.playFlapSound()
    }

    private func handleInput(forPlayer playerIndex: Int) {
        if isReady {
            activateGameplay()
            handleJump(forPlayer: playerIndex)
        } else if isGameActive {
            handleJump(forPlayer: playerIndex)
        }
    }

    // MARK: - iOS / iPadOS Touch Input
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if router.config.playerCount == 1 {
                handleInput(forPlayer: 1)
            } else {
                // 2P: left half = P1, right half = P2
                if location.x < size.width / 2 {
                    handleInput(forPlayer: 1)
                } else {
                    handleInput(forPlayer: 2)
                }
            }
        }
    }
    #endif

    // MARK: - macOS Keyboard Input
    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        // Intentionally do not call super to suppress macOS beep on unhandled keys
        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return }

        if router.config.playerCount == 1 {
            if chars == " " {
                handleInput(forPlayer: 1)
            }
        } else {
            switch chars {
            case "a":
                handleInput(forPlayer: 1)
            case "l":
                handleInput(forPlayer: 2)
            default:
                break
            }
        }
    }
    #endif
}
