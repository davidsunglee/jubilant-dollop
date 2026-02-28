import SpriteKit

enum GameEnvironment: String, CaseIterable, Identifiable {
    case classic
    case jungle
    case underwater
    case arctic
    case desert
    case space

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic:    return "Classic"
        case .jungle:     return "Jungle"
        case .underwater: return "Underwater"
        case .arctic:     return "Arctic"
        case .desert:     return "Desert"
        case .space:      return "Space"
        }
    }

    var backgroundColor: SKColor {
        switch self {
        case .classic:    return .cyan
        case .jungle:     return .systemGreen
        case .underwater: return .blue
        case .arctic:     return SKColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1.0)
        case .desert:     return .systemYellow
        case .space:      return .black
        }
    }

    var obstacleColor: SKColor {
        switch self {
        case .classic:    return .green
        case .jungle:     return .brown
        case .underwater: return .systemPink
        case .arctic:     return .systemBlue
        case .desert:     return .orange
        case .space:      return .purple
        }
    }

    var groundColor: SKColor {
        switch self {
        case .classic:    return SKColor(red: 0.86, green: 0.69, blue: 0.35, alpha: 1.0)
        case .jungle:     return SKColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1.0)
        case .underwater: return SKColor(red: 0.1, green: 0.15, blue: 0.4, alpha: 1.0)
        case .arctic:     return SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        case .desert:     return SKColor(red: 0.76, green: 0.6, blue: 0.3, alpha: 1.0)
        case .space:      return SKColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0)
        }
    }
}
