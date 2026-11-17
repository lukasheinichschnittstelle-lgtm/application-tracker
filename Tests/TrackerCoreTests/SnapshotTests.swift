import AppKit
import SwiftUI
import XCTest
@testable import TrackerCore

/// Renders the window to PNG (light, dark, empty) so the UI can be checked from CI artifacts (R20).
/// Sample data lives only here (T5: no demo in the app).
@MainActor
final class SnapshotTests: XCTestCase {
    func testRenderSnapshots() throws {
        let fonts = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .appendingPathComponent("../../Resources/Fonts").standardized
        for file in try FileManager.default.contentsOfDirectory(at: fonts, includingPropertiesForKeys: nil)
        where file.pathExtension == "ttf" {
            CTFontManagerRegisterFontsForURL(file as CFURL, .process, nil)
        }
        XCTAssertNotNil(NSFont(name: "Archivo-ExtraBold", size: 12), "Archivo not registered")

        let out = URL(fileURLWithPath: ProcessInfo.processInfo.environment["SNAPSHOT_DIR"] ?? NSTemporaryDirectory())
        try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)

        let filled = Store(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let samples: [(String, String, Status, String)] = [
            ("Studio North", "Working student graphic design", .reply, "They asked for the portfolio PDF."),
            ("Example Museum", "Working student content creation", .sent, "Sent CV and portfolio link."),
            ("Agency Two", "Freelance illustration", .interview, "Call on Thursday, 10:00."),
            ("Big Corp", "Working student brand design", .rejected, ""),
            ("Small Press", "Layout freelance", .offer, "Offer by mail, answer by Friday."),
            ("Design Lab", "Working student UX", .toApply, ""),
        ]
        filled.applications = samples.map { company, role, status, note in
            var a = Application(company: company, role: role, link: "example.com/jobs")
            a.setStatus(status, on: Date(timeIntervalSince1970: 1_794_000_000))
            a.note = note
            return a
        }
        let empty = Store(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))

        for (name, store, appearance) in [("light", filled, NSAppearance.Name.aqua), ("dark", filled, .darkAqua),
                                          ("empty-light", empty, .aqua), ("empty-dark", empty, .darkAqua)] {
            let host = NSHostingView(rootView: TrackerView(store: store))
            host.frame = NSRect(x: 0, y: 0, width: 900, height: 1250)
            let window = NSWindow(contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
            window.appearance = NSAppearance(named: appearance)
            window.contentView = host
            host.layoutSubtreeIfNeeded()
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
            let rep = try XCTUnwrap(host.bitmapImageRepForCachingDisplay(in: host.bounds))
            host.cacheDisplay(in: host.bounds, to: rep)
            let png = try XCTUnwrap(rep.representation(using: .png, properties: [:]))
            try png.write(to: out.appendingPathComponent("\(name).png"))
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: out.appendingPathComponent("dark.png").path))
    }
}
