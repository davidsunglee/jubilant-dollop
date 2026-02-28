import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    let router: GameRouter
    var players: [PlayerNode] = []
    var parallaxBackground: ParallaxBackground?
    var lastUpdateTime: TimeInterval = 0
    var isGameActive: Bool = false
    private var isSetup: Bool = false

    // Tuning constants
    let gravity: CGFloat = -5.0
    let pipeSpeed: CGFloat = 150
    let pipeSpawnInterval: TimeInterval = 2.0
    let pipeWidth: CGFloat = 60
    let gapHeight: CGFloat = 180
    let jumpImpulse: CGFloat = 300

    // Scored pipe tracking (to prevent double-counting)
    var scoredPipes: Set<SKNode> = []

    // MARK: - Init

    init(router: GameRouter) {
        self.router = router
        super.init(size: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupScene()

        #if os(iOS)
        view.isMultipleTouchEnabled = true
        #endif

        #if os(macOS)
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(self)
        }
        #endif
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        setupScene()
    }

    private func setupScene() {
        guard !isSetup else { return }
        guard size.width > 0, size.height > 0 else { return }
        isSetup = true

        removeAllChildren()
        removeAllActions()
        players.removeAll()
        scoredPipes.removeAll()
        lastUpdateTime = 0

        setupWorld()
        setupPlayers()
        setupBackground()
        setupBoundaries()
        startSpawning()
        isGameActive = true
        AudioManager.shared.playBGM()
    }

    // MARK: - Setup

    private func setupWorld() {
        backgroundColor = router.config.environment.backgroundColor
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.contactDelegate = self
    }

    private func setupPlayers() {
        let config = router.config

        // Player 1
        let p1 = PlayerNode(playerIndex: 1, character: config.player1Character)
        let p1X: CGFloat
        if config.playerCount == 2 {
            p1X = size.width * 0.25
        } else {
            p1X = size.width * 0.3
        }
        p1.position = CGPoint(x: p1X, y: size.height * 0.5)
        addChild(p1)
        players.append(p1)

        // Player 2 (if 2P mode)
        if config.playerCount == 2 {
            let p2 = PlayerNode(playerIndex: 2, character: config.player2Character)
            p2.position = CGPoint(x: size.width * 0.75, y: size.height * 0.5)
            addChild(p2)
            players.append(p2)

            // Divider line
            let divider = SKShapeNode(rectOf: CGSize(width: 2, height: size.height))
            divider.fillColor = .white
            divider.strokeColor = .clear
            divider.alpha = 0.3
            divider.position = CGPoint(x: size.width / 2, y: size.height / 2)
            divider.zPosition = 5
            divider.name = "divider"
            addChild(divider)
        }
    }

    private func setupBackground() {
        parallaxBackground = ParallaxBackground(
            color: router.config.environment.groundColor,
            size: CGSize(width: size.width, height: 40),
            scrollSpeed: pipeSpeed,
            parent: self
        )
    }

    private func setupBoundaries() {
        // Top boundary
        let topBoundary = SKNode()
        topBoundary.position = CGPoint(x: size.width / 2, y: size.height + 20)
        topBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        topBoundary.physicsBody?.isDynamic = false
        topBoundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        topBoundary.physicsBody?.contactTestBitMask = PhysicsCategory.player
        topBoundary.physicsBody?.collisionBitMask = PhysicsCategory.player
        topBoundary.name = "boundary"
        addChild(topBoundary)

        // Bottom boundary
        let bottomBoundary = SKNode()
        bottomBoundary.position = CGPoint(x: size.width / 2, y: -20)
        bottomBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        bottomBoundary.physicsBody?.isDynamic = false
        bottomBoundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        bottomBoundary.physicsBody?.contactTestBitMask = PhysicsCategory.player
        bottomBoundary.physicsBody?.collisionBitMask = PhysicsCategory.player
        bottomBoundary.name = "boundary"
        addChild(bottomBoundary)
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        parallaxBackground?.update(deltaTime: dt)

        // Lock player X positions
        for player in players {
            guard player.isAlive else { continue }
            let targetX: CGFloat
            if router.config.playerCount == 2 {
                targetX = player.playerIndex == 1 ? size.width * 0.25 : size.width * 0.75
            } else {
                targetX = size.width * 0.3
            }
            player.position.x = targetX

            // Clamp rotation based on velocity
            if let vy = player.physicsBody?.velocity.dy {
                let rotation = max(-0.5, min(0.5, vy / 500))
                player.zRotation = rotation
            }
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let (bodyA, bodyB) = (contact.bodyA, contact.bodyB)
        let categoryA = bodyA.categoryBitMask
        let categoryB = bodyB.categoryBitMask

        // Find player and other node
        let playerBody: SKPhysicsBody
        let otherCategory: UInt32

        if categoryA == PhysicsCategory.player {
            playerBody = bodyA
            otherCategory = categoryB
        } else if categoryB == PhysicsCategory.player {
            playerBody = bodyB
            otherCategory = categoryA
        } else {
            return
        }

        guard let playerNode = playerBody.node as? PlayerNode, playerNode.isAlive else { return }

        if otherCategory == PhysicsCategory.scoreZone {
            // Score!
            let scoreNode = (categoryA == PhysicsCategory.scoreZone) ? bodyA.node : bodyB.node
            guard let scoreNode = scoreNode, !scoredPipes.contains(scoreNode) else { return }
            scoredPipes.insert(scoreNode)

            DispatchQueue.main.async { [weak self] in
                self?.router.incrementScore(forPlayer: playerNode.playerIndex)
            }
            AudioManager.shared.playScoreSound(on: self)

        } else if otherCategory == PhysicsCategory.obstacle || otherCategory == PhysicsCategory.boundary {
            // Death
            playerNode.die()
            AudioManager.shared.playCollisionSound(on: self)

            DispatchQueue.main.async { [weak self] in
                self?.router.playerDied(playerNode.playerIndex)
            }

            // Check if all players dead
            if players.allSatisfy({ !$0.isAlive }) {
                isGameActive = false
                removeAllActions()
                scoredPipes.removeAll()
                AudioManager.shared.stopBGM()
            }
        }
    }
}
