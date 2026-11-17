// Renders the app icon: a plain "B" (FT-13) in Archivo ExtraBold on the Gepard dark page colour.
// Usage: swift scripts/make-icon.swift <Archivo-ExtraBold.ttf> <out.png>
import AppKit

let args = CommandLine.arguments
CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: args[1]) as CFURL, .process, nil)
let size = 1024.0
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                           bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor(srgbRed: 0x16 / 255, green: 0x15 / 255, blue: 0x15 / 255, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185).fill()
let text = NSAttributedString(string: "B", attributes: [
    .font: NSFont(name: "Archivo-ExtraBold", size: 600)!,
    .foregroundColor: NSColor(srgbRed: 0xf3 / 255, green: 0xf1 / 255, blue: 0xe2 / 255, alpha: 1),
])
let bounds = text.size()
text.draw(at: NSPoint(x: (size - bounds.width) / 2, y: (size - bounds.height) / 2))
NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
