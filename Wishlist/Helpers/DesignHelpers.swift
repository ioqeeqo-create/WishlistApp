import SwiftUI

// MARK: - Liquid Glass Card Modifier
struct LiquidGlassCard: ViewModifier {
    let color: Color
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(color.opacity(0.18))
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.35), color.opacity(0.12), .white.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(LinearGradient(
                            colors: [.white.opacity(0.6), color.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
                }
            )
            .shadow(color: color.opacity(isPressed ? 0.15 : 0.3),
                    radius: isPressed ? 8 : 18, x: 0, y: isPressed ? 4 : 10)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isPressed)
    }
}

extension View {
    func liquidGlassCard(color: Color, isPressed: Bool = false) -> some View {
        modifier(LiquidGlassCard(color: color, isPressed: isPressed))
    }
}

// MARK: - Color helpers
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var v: UInt64 = 0; Scanner(string: h).scanHexInt64(&v)
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >>  8) & 0xFF) / 255
        let b = Double( v        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

// MARK: - Corner shape
struct RoundedCorner: Shape {
    var radius: CGFloat; var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: .init(width: radius, height: radius)).cgPath)
    }
}

extension View {
    func cornerRadius(_ r: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: r, corners: corners))
    }
}

// MARK: - Presets
struct WishlistPreset {
    static let colors  = ["#A78BFA","#F472B6","#34D399","#60A5FA",
                           "#FBBF24","#F87171","#818CF8","#2DD4BF"]
    static let emojis  = ["🎁","🛍","📚","✈️","💻","🎮","👗","🏠",
                           "🎵","🍕","🌸","⚽️","🎨","💄","🐾","🌟"]
    static let names   = ["Подарки на ДР","Техника","Книги","Путешествия"]
}

// MARK: - Haptics
struct HapticManager {
    static func impact(_ s: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: s).impactOccurred()
    }
    static func notification(_ t: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(t)
    }
}
