import Foundation
import SpriteKit

enum GameCharacter: String, CaseIterable, Identifiable {
    case avian
    case wingedPig
    case flyingSquirrel
    case pegasus
    case wingedTurtle
    case bat

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .avian:          return "Avian"
        case .wingedPig:      return "Winged Pig"
        case .flyingSquirrel: return "Flying Squirrel"
        case .pegasus:        return "Pegasus"
        case .wingedTurtle:   return "Winged Turtle"
        case .bat:            return "Bat"
        }
    }

    var color: SKColor {
        switch self {
        case .avian:          return .yellow
        case .wingedPig:      return .systemPink
        case .flyingSquirrel: return .brown
        case .pegasus:        return .white
        case .wingedTurtle:   return .green
        case .bat:            return .darkGray
        }
    }

    var physicsBodySize: CGSize {
        switch self {
        case .avian:          return CGSize(width: 30, height: 30)
        case .wingedPig:      return CGSize(width: 36, height: 28)
        case .flyingSquirrel: return CGSize(width: 40, height: 20)
        case .pegasus:        return CGSize(width: 38, height: 32)
        case .wingedTurtle:   return CGSize(width: 34, height: 30)
        case .bat:            return CGSize(width: 24, height: 24)
        }
    }

    var useCircleBody: Bool {
        switch self {
        case .avian, .wingedTurtle, .bat: return true
        default: return false
        }
    }

    var circleRadius: CGFloat {
        switch self {
        case .avian:       return 15
        case .wingedTurtle: return 17
        case .bat:         return 12
        default:           return 15
        }
    }
}
