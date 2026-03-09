import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let ccBackground     = Color(hex: "0A0A0F")
    static let ccSurface        = Color(hex: "131318")
    static let ccCard           = Color(hex: "1C1C24")
    static let ccCardElevated   = Color(hex: "242430")
    static let ccBorder         = Color(hex: "2A2A38")

    // Accent — Electric Acid Lime
    static let ccAccent         = Color(hex: "C8F53C")
    static let ccAccentDim      = Color(hex: "C8F53C").opacity(0.15)
    static let ccAccentGlow     = Color(hex: "C8F53C").opacity(0.08)

    // Semantic
    static let ccGreen          = Color(hex: "34D399")
    static let ccRed            = Color(hex: "F87171")
    static let ccOrange         = Color(hex: "FB923C")
    static let ccBlue           = Color(hex: "60A5FA")
    static let ccPurple         = Color(hex: "A78BFA")

    // Text
    static let ccTextPrimary    = Color(hex: "F0F0F8")
    static let ccTextSecondary  = Color(hex: "8888A8")
    static let ccTextTertiary   = Color(hex: "55556A")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8&0xFF,int&0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
        default:(a,r,g,b) = (1,1,1,0)
        }
        self.init(.sRGB,red:Double(r)/255,green:Double(g)/255,blue:Double(b)/255,opacity:Double(a)/255)
    }
}

// MARK: - Typography
struct CCFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Spacing
struct CCSpacing {
    static let xs: CGFloat  = 4
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 20
    static let xxl: CGFloat = 28
    static let xxxl: CGFloat = 40
}

// MARK: - Corner Radius
struct CCRadius {
    static let sm: CGFloat  = 10
    static let md: CGFloat  = 14
    static let lg: CGFloat  = 18
    static let xl: CGFloat  = 24
    static let pill: CGFloat = 100
}

// MARK: - Card Modifier
struct CCCardModifier: ViewModifier {
    var elevated: Bool = false
    func body(content: Content) -> some View {
        content
            .background(elevated ? Color.ccCardElevated : Color.ccCard)
            .clipShape(RoundedRectangle(cornerRadius: CCRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CCRadius.lg)
                    .stroke(Color.ccBorder, lineWidth: 0.5)
            )
    }
}

extension View {
    func ccCard(elevated: Bool = false) -> some View {
        modifier(CCCardModifier(elevated: elevated))
    }

    func ccGlow(color: Color = .ccAccent, radius: CGFloat = 12) -> some View {
        shadow(color: color.opacity(0.35), radius: radius, x: 0, y: 4)
    }
}

// MARK: - Section Header
struct CCSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CCFont.display(13, weight: .semibold))
                    .foregroundColor(.ccTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                if let sub = subtitle {
                    Text(sub)
                        .font(CCFont.body(11))
                        .foregroundColor(.ccTextTertiary)
                }
            }
            Spacer()
            if let action = action, let handler = onAction {
                Button(action: handler) {
                    Text(action)
                        .font(CCFont.body(13, weight: .medium))
                        .foregroundColor(.ccAccent)
                }
            }
        }
    }
}

// MARK: - Primary Button
struct CCPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDestructive: Bool = false

    init(_ title: String, icon: String? = nil, isLoading: Bool = false, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.action = action
        self.isLoading = isLoading; self.isDestructive = isDestructive
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: CCSpacing.sm) {
                if isLoading {
                    ProgressView().tint(.ccBackground).scaleEffect(0.85)
                } else {
                    if let icon = icon { Image(systemName: icon) }
                    Text(title).font(CCFont.display(16, weight: .semibold))
                }
            }
            .foregroundColor(.ccBackground)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(isDestructive ? Color.ccRed : Color.ccAccent)
            .clipShape(RoundedRectangle(cornerRadius: CCRadius.md))
            .ccGlow(color: isDestructive ? .ccRed : .ccAccent)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ghost Button
struct CCGhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CCFont.body(15, weight: .medium))
                .foregroundColor(.ccTextSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay(RoundedRectangle(cornerRadius: CCRadius.md).stroke(Color.ccBorder))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Acccent Badge
struct CCBadge: View {
    let text: String
    var color: Color = .ccAccent

    var body: some View {
        Text(text)
            .font(CCFont.mono(11, weight: .bold))
            .foregroundColor(color == .ccAccent ? .ccBackground : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color == .ccAccent ? color : color.opacity(0.18))
            .clipShape(Capsule())
    }
}

// MARK: - Divider
struct CCDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.ccBorder)
            .frame(height: 0.5)
    }
}

// MARK: - Progress Bar
struct CCProgressBar: View {
    let value: Double    // 0–1
    var color: Color = .ccAccent
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color.opacity(0.15))
                    .frame(height: height)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(value, 1.0), height: height)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: value)
            }
        }
        .frame(height: height)
    }
}
