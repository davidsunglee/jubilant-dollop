import SpriteKit

class CharacterRenderer {
    static func createNode(for character: GameCharacter) -> SKNode {
        let container = SKNode()
        container.name = "characterVisual"

        switch character {
        case .avian:          buildAvian(in: container)
        case .wingedPig:      buildWingedPig(in: container)
        case .flyingSquirrel: buildFlyingSquirrel(in: container)
        case .pegasus:        buildPegasus(in: container)
        case .wingedTurtle:   buildWingedTurtle(in: container)
        case .bat:            buildBat(in: container)
        }

        return container
    }

    // MARK: - Avian
    private static func buildAvian(in container: SKNode) {
        // Body - round yellow
        let body = SKShapeNode(circleOfRadius: 13)
        body.fillColor = .yellow
        body.strokeColor = .orange
        body.lineWidth = 1.5
        container.addChild(body)

        // Belly - lighter oval
        let belly = SKShapeNode(ellipseOf: CGSize(width: 16, height: 12))
        belly.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1)
        belly.strokeColor = .clear
        belly.position = CGPoint(x: 1, y: -2)
        container.addChild(belly)

        // Eye - white with black pupil
        let eye = SKShapeNode(circleOfRadius: 4)
        eye.fillColor = .white
        eye.strokeColor = .darkGray
        eye.lineWidth = 0.5
        eye.position = CGPoint(x: 6, y: 4)
        container.addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: 2)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: 7, y: 4)
        container.addChild(pupil)

        // Beak - orange triangle (using path)
        let beakPath = CGMutablePath()
        beakPath.move(to: CGPoint(x: 12, y: 2))
        beakPath.addLine(to: CGPoint(x: 20, y: 0))
        beakPath.addLine(to: CGPoint(x: 12, y: -2))
        beakPath.closeSubpath()
        let beak = SKShapeNode(path: beakPath)
        beak.fillColor = .orange
        beak.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1)
        beak.lineWidth = 1
        container.addChild(beak)

        // Tail feathers - 2 small ellipses fanning left
        for i in 0..<2 {
            let feather = SKShapeNode(ellipseOf: CGSize(width: 10, height: 4))
            feather.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1)
            feather.strokeColor = .orange
            feather.lineWidth = 0.5
            feather.position = CGPoint(x: -14, y: CGFloat(i) * 4 - 2)
            feather.zRotation = CGFloat(i) * 0.3 - 0.15
            container.addChild(feather)
        }

        // Wing - feathered ellipse
        let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 8))
        wing.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 0.9)
        wing.strokeColor = .orange
        wing.lineWidth = 0.5
        wing.position = CGPoint(x: -4, y: 6)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 6, duration: 0.15)
    }

    // MARK: - Winged Pig
    private static func buildWingedPig(in container: SKNode) {
        // Body - rounded pink rectangle
        let body = SKShapeNode(rectOf: CGSize(width: 32, height: 26), cornerRadius: 10)
        body.fillColor = .systemPink
        body.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        body.lineWidth = 1.5
        container.addChild(body)

        // Snout - lighter pink circle
        let snout = SKShapeNode(circleOfRadius: 6)
        snout.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.75, alpha: 1)
        snout.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        snout.lineWidth = 1
        snout.position = CGPoint(x: 12, y: -2)
        container.addChild(snout)

        // Nostrils - two small dots
        for dx in [-2, 2] as [CGFloat] {
            let nostril = SKShapeNode(circleOfRadius: 1.5)
            nostril.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
            nostril.strokeColor = .clear
            nostril.position = CGPoint(x: 12 + dx, y: -2)
            container.addChild(nostril)
        }

        // Eyes - beady
        for dy in [4] as [CGFloat] {
            let eye = SKShapeNode(circleOfRadius: 2.5)
            eye.fillColor = .white
            eye.strokeColor = .darkGray
            eye.lineWidth = 0.5
            eye.position = CGPoint(x: 6, y: dy)
            container.addChild(eye)

            let pupil = SKShapeNode(circleOfRadius: 1.5)
            pupil.fillColor = .black
            pupil.strokeColor = .clear
            pupil.position = CGPoint(x: 7, y: dy)
            container.addChild(pupil)
        }

        // Ears - two small triangles on top
        for dx in [-5, 5] as [CGFloat] {
            let earPath = CGMutablePath()
            earPath.move(to: CGPoint(x: dx - 3, y: 13))
            earPath.addLine(to: CGPoint(x: dx, y: 20))
            earPath.addLine(to: CGPoint(x: dx + 3, y: 13))
            earPath.closeSubpath()
            let ear = SKShapeNode(path: earPath)
            ear.fillColor = .systemPink
            ear.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
            ear.lineWidth = 1
            container.addChild(ear)
        }

        // Curly tail - small circle on left
        let tail = SKShapeNode(circleOfRadius: 4)
        tail.fillColor = .systemPink
        tail.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        tail.lineWidth = 1
        tail.position = CGPoint(x: -19, y: 2)
        container.addChild(tail)

        // Wings - comically small
        let wing = SKShapeNode(ellipseOf: CGSize(width: 10, height: 6))
        wing.fillColor = SKColor.systemPink.withAlphaComponent(0.8)
        wing.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.4, alpha: 1)
        wing.lineWidth = 0.5
        wing.position = CGPoint(x: -6, y: 8)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 4, duration: 0.12)
    }

    // MARK: - Flying Squirrel
    private static func buildFlyingSquirrel(in container: SKNode) {
        // Body - wide brown ellipse
        let body = SKShapeNode(ellipseOf: CGSize(width: 34, height: 18))
        body.fillColor = .brown
        body.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
        body.lineWidth = 1.5
        container.addChild(body)

        // Belly - lighter brown
        let belly = SKShapeNode(ellipseOf: CGSize(width: 22, height: 10))
        belly.fillColor = SKColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)
        belly.strokeColor = .clear
        belly.position = CGPoint(x: 0, y: -2)
        container.addChild(belly)

        // Head - small rounded shape extending right
        let head = SKShapeNode(circleOfRadius: 8)
        head.fillColor = .brown
        head.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
        head.lineWidth = 1
        head.position = CGPoint(x: 16, y: 4)
        container.addChild(head)

        // Big round eyes (squirrels have large eyes)
        let eye = SKShapeNode(circleOfRadius: 3.5)
        eye.fillColor = .white
        eye.strokeColor = .darkGray
        eye.lineWidth = 0.5
        eye.position = CGPoint(x: 19, y: 6)
        container.addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: 2)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: 20, y: 6)
        container.addChild(pupil)

        // Small nose
        let nose = SKShapeNode(circleOfRadius: 1.5)
        nose.fillColor = SKColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1)
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 23, y: 3)
        container.addChild(nose)

        // Bushy tail - overlapping ellipses curving up-left
        for i in 0..<3 {
            let segment = SKShapeNode(ellipseOf: CGSize(width: 8, height: 6))
            segment.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 0.9)
            segment.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)
            segment.lineWidth = 0.5
            segment.position = CGPoint(x: -17 - CGFloat(i) * 3, y: CGFloat(i) * 5)
            container.addChild(segment)
        }

        // Membrane wings - flat wide shape
        let wing = SKShapeNode(ellipseOf: CGSize(width: 20, height: 5))
        wing.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.7)
        wing.strokeColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 0.5)
        wing.lineWidth = 0.5
        wing.position = CGPoint(x: 0, y: 10)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 3, duration: 0.25)
    }

    // MARK: - Pegasus
    private static func buildPegasus(in container: SKNode) {
        // Body - white rectangle
        let body = SKShapeNode(rectOf: CGSize(width: 32, height: 22), cornerRadius: 6)
        body.fillColor = .white
        body.strokeColor = .lightGray
        body.lineWidth = 1.5
        container.addChild(body)

        // Neck + Head - elongated upward-right
        let neck = SKShapeNode(rectOf: CGSize(width: 8, height: 16), cornerRadius: 3)
        neck.fillColor = .white
        neck.strokeColor = .lightGray
        neck.lineWidth = 1
        neck.position = CGPoint(x: 14, y: 12)
        neck.zRotation = -0.3
        container.addChild(neck)

        let head = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
        head.fillColor = .white
        head.strokeColor = .lightGray
        head.lineWidth = 1
        head.position = CGPoint(x: 20, y: 18)
        container.addChild(head)

        // Eye
        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 23, y: 19)
        container.addChild(eye)

        // Pointed ears
        for dx in [-2, 2] as [CGFloat] {
            let earPath = CGMutablePath()
            earPath.move(to: CGPoint(x: 18 + dx, y: 22))
            earPath.addLine(to: CGPoint(x: 19 + dx, y: 28))
            earPath.addLine(to: CGPoint(x: 21 + dx, y: 22))
            earPath.closeSubpath()
            let ear = SKShapeNode(path: earPath)
            ear.fillColor = .white
            ear.strokeColor = .lightGray
            ear.lineWidth = 0.5
            container.addChild(ear)
        }

        // Flowing tail - overlapping curved ellipses
        for i in 0..<3 {
            let tailPiece = SKShapeNode(ellipseOf: CGSize(width: 10, height: 5))
            tailPiece.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 0.9)
            tailPiece.strokeColor = .lightGray
            tailPiece.lineWidth = 0.5
            tailPiece.position = CGPoint(x: -18 - CGFloat(i) * 4, y: CGFloat(i) * 3 - 2)
            tailPiece.zRotation = CGFloat(i) * 0.2
            container.addChild(tailPiece)
        }

        // Legs - two small rectangles at bottom
        for dx in [-6, 6] as [CGFloat] {
            let leg = SKShapeNode(rectOf: CGSize(width: 3, height: 8), cornerRadius: 1)
            leg.fillColor = .white
            leg.strokeColor = .lightGray
            leg.lineWidth = 0.5
            leg.position = CGPoint(x: dx, y: -15)
            container.addChild(leg)
        }

        // Large angelic wings
        let wing = SKShapeNode(ellipseOf: CGSize(width: 20, height: 12))
        wing.fillColor = SKColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 0.9)
        wing.strokeColor = .lightGray
        wing.lineWidth = 0.5
        wing.position = CGPoint(x: -2, y: 14)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 10, duration: 0.2)
    }

    // MARK: - Winged Turtle
    private static func buildWingedTurtle(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 17)
        body.fillColor = .green
        body.strokeColor = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1)
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 14, height: 9))
        wing.fillColor = SKColor.green.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -10, y: 3)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 5, duration: 0.08)
    }

    // MARK: - Bat
    private static func buildBat(in container: SKNode) {
        let body = SKShapeNode(circleOfRadius: 12)
        body.fillColor = .darkGray
        body.strokeColor = .black
        body.lineWidth = 2
        container.addChild(body)

        let wing = SKShapeNode(ellipseOf: CGSize(width: 10, height: 7))
        wing.fillColor = SKColor.darkGray.withAlphaComponent(0.7)
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -7, y: 4)
        wing.name = "wing"
        container.addChild(wing)
        addWingAnimation(to: wing, range: 8, duration: 0.18)
    }

    // MARK: - Wing Animation Helper
    private static func addWingAnimation(to wing: SKShapeNode, range: CGFloat, duration: TimeInterval) {
        let flapUp = SKAction.moveBy(x: 0, y: range, duration: duration)
        let flapDown = SKAction.moveBy(x: 0, y: -range, duration: duration)
        let flap = SKAction.sequence([flapUp, flapDown])
        wing.run(SKAction.repeatForever(flap))
    }
}
