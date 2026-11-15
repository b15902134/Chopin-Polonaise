import SwiftUI
import UIKit

extension Font {
    static func biauKai(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let size: CGFloat = switch style {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }

        let latinFont = UIFont(name: "TimesNewRomanPSMT", size: size)
            ?? UIFont.systemFont(ofSize: size)
        let kaiDescriptor = UIFontDescriptor(name: "TW-MOE-Std-Kai", size: size)
        let mixedDescriptor = latinFont.fontDescriptor.addingAttributes([
            .cascadeList: [kaiDescriptor]
        ])
        let mixedFont = UIFont(descriptor: mixedDescriptor, size: size)
        let scaledFont = UIFontMetrics(forTextStyle: style.uiTextStyle)
            .scaledFont(for: mixedFont)

        return Font(scaledFont).weight(weight)
    }
}

private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .body: .body
        case .callout: .callout
        case .subheadline: .subheadline
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        @unknown default: .body
        }
    }
}

enum ChopinTheme {
    static let paper = adaptiveColor(
        light: UIColor(red: 0.965, green: 0.945, blue: 0.905, alpha: 1),
        dark: UIColor(red: 0.075, green: 0.065, blue: 0.06, alpha: 1)
    )
    static let surface = adaptiveColor(
        light: UIColor(white: 1, alpha: 1),
        dark: UIColor(red: 0.13, green: 0.115, blue: 0.105, alpha: 1)
    )
    static let parchment = adaptiveColor(
        light: UIColor(red: 0.91, green: 0.86, blue: 0.76, alpha: 1),
        dark: UIColor(red: 0.19, green: 0.16, blue: 0.13, alpha: 1)
    )
    static let ink = adaptiveColor(
        light: UIColor(red: 0.15, green: 0.105, blue: 0.08, alpha: 1),
        dark: UIColor(red: 0.94, green: 0.91, blue: 0.85, alpha: 1)
    )
    static let walnut = adaptiveColor(
        light: UIColor(red: 0.30, green: 0.17, blue: 0.11, alpha: 1),
        dark: UIColor(red: 0.50, green: 0.30, blue: 0.22, alpha: 1)
    )
    static let burgundy = adaptiveColor(
        light: UIColor(red: 0.38, green: 0.08, blue: 0.11, alpha: 1),
        dark: UIColor(red: 0.82, green: 0.30, blue: 0.37, alpha: 1)
    )
    static let antiqueGold = adaptiveColor(
        light: UIColor(red: 0.67, green: 0.50, blue: 0.24, alpha: 1),
        dark: UIColor(red: 0.78, green: 0.65, blue: 0.42, alpha: 1)
    )

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

struct ArchiveCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                LinearGradient(
                    colors: [ChopinTheme.surface.opacity(0.94), ChopinTheme.paper.opacity(0.96)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ChopinTheme.antiqueGold.opacity(0.24), lineWidth: 1)
            }
            .shadow(color: ChopinTheme.ink.opacity(0.07), radius: 12, y: 5)
    }
}

extension View {
    func archiveCard() -> some View {
        modifier(ArchiveCardModifier())
    }
}

struct OrnamentDivider: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(ChopinTheme.antiqueGold.opacity(0.45))
                .frame(height: 1)
            Image(systemName: "music.note")
                .font(.caption)
                .foregroundStyle(ChopinTheme.antiqueGold)
            Rectangle()
                .fill(ChopinTheme.antiqueGold.opacity(0.45))
                .frame(height: 1)
        }
        .accessibilityHidden(true)
    }
}

struct EditorialSectionTitle: View {
    let eyebrow: String
    let title: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(eyebrow)
                .font(.biauKai(.caption2, weight: .semibold))
                .tracking(2)
                .foregroundStyle(ChopinTheme.burgundy)
            Label(title, systemImage: symbol)
                .font(.biauKai(.title2, weight: .bold))
                .foregroundStyle(ChopinTheme.ink)
        }
    }
}
