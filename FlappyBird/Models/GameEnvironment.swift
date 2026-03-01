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

    var renderer: EnvironmentRenderer {
        switch self {
        case .classic:    return ClassicEnvironmentRenderer()
        case .jungle:     return JungleEnvironmentRenderer()
        case .underwater: return UnderwaterEnvironmentRenderer()
        case .arctic:     return ArcticEnvironmentRenderer()
        case .desert:     return DesertEnvironmentRenderer()
        case .space:      return SpaceEnvironmentRenderer()
        }
    }
}
