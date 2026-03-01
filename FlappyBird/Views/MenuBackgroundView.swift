import SwiftUI

struct FloatingCloud: View {
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let xOffset: CGFloat
    let yOffset: CGFloat

    @State private var animate = false

    var body: some View {
        Ellipse()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size * 0.6)
            .blur(radius: size * 0.15)
            .offset(
                x: animate ? xOffset : -xOffset,
                y: animate ? yOffset : -yOffset
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    animate = true
                }
            }
    }
}

enum MenuScreenTint {
    case neutral    // title
    case cool       // character select
    case warm       // environment select

    var topColor: Color {
        switch self {
        case .neutral: return Color(red: 0.55, green: 0.78, blue: 0.95)
        case .cool:    return Color(red: 0.50, green: 0.75, blue: 0.98)
        case .warm:    return Color(red: 0.60, green: 0.78, blue: 0.92)
        }
    }

    var midColor: Color {
        switch self {
        case .neutral: return Color(red: 0.85, green: 0.92, blue: 0.98)
        case .cool:    return Color(red: 0.82, green: 0.90, blue: 1.00)
        case .warm:    return Color(red: 0.88, green: 0.92, blue: 0.95)
        }
    }

    var bottomColor: Color {
        switch self {
        case .neutral: return Color(red: 0.98, green: 0.90, blue: 0.85)
        case .cool:    return Color(red: 0.92, green: 0.90, blue: 0.92)
        case .warm:    return Color(red: 1.00, green: 0.92, blue: 0.85)
        }
    }
}

struct MenuBackgroundView: View {
    var tint: MenuScreenTint = .neutral

    private let clouds: [(size: CGFloat, opacity: Double, duration: Double, xOffset: CGFloat, yOffset: CGFloat)] = [
        (120, 0.15, 12, 40, 15),
        (80, 0.12, 10, -30, 20),
        (100, 0.18, 14, 50, -10),
        (60, 0.10, 9, -20, 25),
        (90, 0.14, 11, 35, -18),
        (70, 0.16, 13, -45, 12),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [tint.topColor, tint.midColor, tint.bottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(Array(clouds.enumerated()), id: \.offset) { index, cloud in
                    FloatingCloud(
                        size: cloud.size,
                        opacity: cloud.opacity,
                        duration: cloud.duration,
                        xOffset: cloud.xOffset,
                        yOffset: cloud.yOffset
                    )
                    .position(
                        x: geo.size.width * [0.15, 0.75, 0.5, 0.85, 0.3, 0.65][index],
                        y: geo.size.height * [0.2, 0.35, 0.55, 0.15, 0.7, 0.45][index]
                    )
                }
            }
            .ignoresSafeArea()
        }
    }
}
