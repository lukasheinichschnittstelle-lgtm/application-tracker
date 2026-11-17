import AppKit
import SwiftUI

/// Colours and fonts from the Gepard design (#549, src/design/gepard.css). Light/dark follows the system.
enum Theme {
    static let page = dynamic(0xffffff, 0x161515)
    static let card = dynamic(0xffffff, 0xffffff, darkAlpha: 0.05)
    static let field = dynamic(0xffffff, 0x000000, darkAlpha: 0.25)
    static let ink = dynamic(0x111516, 0xf3f1e2)
    static let secondary = dynamic(0x5c6064, 0xf3f1e2, darkAlpha: 0.72)
    static let muted = dynamic(0x8a8d90, 0xf3f1e2, darkAlpha: 0.5)
    static let edge = dynamic(0xe4e4e1, 0xf3f1e2, darkAlpha: 0.12)
    static let recessed = dynamic(0x111516, 0xf3f1e2, lightAlpha: 0.05, darkAlpha: 0.06)
    static let onPrimary = dynamic(0xffffff, 0x161515)
    static let akzent = dynamic(0x2f1b9c, 0x8b7cf6)
    static let rot = dynamic(0xc4302b, 0xf87171)
    static let gelb = dynamic(0xa16207, 0xeab308)
    static let gruen = dynamic(0x2f7a3e, 0x86c79a)

    static func head(_ size: CGFloat) -> Font { .custom("Archivo-ExtraBold", size: size) }
    static func text(_ size: CGFloat = 14) -> Font { .custom("Geist-Regular", size: size) }
    static func medium(_ size: CGFloat = 14) -> Font { .custom("Geist-Medium", size: size) }
    static func mono(_ size: CGFloat = 12) -> Font { .custom("GeistMono-Regular", size: size) }

    static func color(for status: Status) -> Color {
        switch status {
        case .toApply: muted
        case .sent, .interview: akzent
        case .reply: gelb
        case .rejected: rot
        case .offer: gruen
        }
    }

    private static func dynamic(_ light: UInt32, _ dark: UInt32, lightAlpha: CGFloat = 1, darkAlpha: CGFloat = 1) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? rgb(dark, darkAlpha) : rgb(light, lightAlpha)
        })
    }

    private static func rgb(_ hex: UInt32, _ alpha: CGFloat) -> NSColor {
        NSColor(srgbRed: CGFloat(hex >> 16 & 0xff) / 255, green: CGFloat(hex >> 8 & 0xff) / 255,
                blue: CGFloat(hex & 0xff) / 255, alpha: alpha)
    }
}

/// Square-ish buttons (radius 3) as in the Gepard design; primary is ink on page.
struct GepardButton: ButtonStyle {
    var primary = false
    var destructive = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.medium(13))
            .padding(.horizontal, 12).padding(.vertical, 6)
            .foregroundStyle(primary ? Theme.onPrimary : destructive ? Theme.rot : Theme.ink)
            .background(primary ? Theme.ink : Theme.recessed, in: RoundedRectangle(cornerRadius: 3))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Dark mode only: four soft colour fields behind the panel, like the radial gradients in gepard.css --nebel.
struct Nebel: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        if scheme == .dark {
            GeometryReader { g in
                ZStack {
                    blob(0x12266e, 0.15, 0.20, 0.40, 0.60, g.size)
                    blob(0x4a3d22, 0.85, 0.30, 0.40, 0.60, g.size)
                    blob(0x3b2f4a, 0.60, 0.90, 0.45, 0.60, g.size)
                    blob(0x183c52, 0.30, 0.85, 0.35, 0.50, g.size)
                }
                .opacity(0.55)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    /// One CSS radial-gradient(rx% ry% at x% y%, colour, transparent).
    private func blob(_ hex: UInt32, _ x: CGFloat, _ y: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ size: CGSize) -> some View {
        let color = Color(nsColor: NSColor(srgbRed: CGFloat(hex >> 16 & 0xff) / 255, green: CGFloat(hex >> 8 & 0xff) / 255,
                                           blue: CGFloat(hex & 0xff) / 255, alpha: 1))
        return EllipticalGradient(colors: [color, color.opacity(0)], center: .center,
                                  startRadiusFraction: 0, endRadiusFraction: 0.5)
            .frame(width: size.width * rx * 2, height: size.height * ry * 2)
            .position(x: size.width * x, y: size.height * y)
    }
}

/// Plain text field with the Gepard field look.
struct Field: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(Theme.text())
            .padding(8)
            .background(Theme.field, in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.edge))
    }
}
