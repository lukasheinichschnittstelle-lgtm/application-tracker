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
            if !note.isEmpty { a.notes = [Note(text: note, date: Date(timeIntervalSince1970: 1_794_100_000))] }
            return a
        }
        filled.applications[0].nextStep = "Send portfolio PDF"
        filled.applications[0].nextStepDate = Date(timeIntervalSince1970: 1_794_000_000)  // past: shown as due
        filled.applications[2].nextStep = "Prepare questions"
        filled.applications[2].nextStepDate = Date.now.addingTimeInterval(86_400 * 30)
        let empty = Store(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))

        for (name, store, appearance) in [("light", filled, NSAppearance.Name.aqua), ("dark", filled, .darkAqua),
                                          ("empty-light", empty, .aqua), ("empty-dark", empty, .darkAqua)] {
            try render(TrackerView(store: store), size: NSSize(width: 900, height: 1250), appearance: appearance,
                       to: out.appendingPathComponent("\(name).png"))
        }
        // One expanded row with a multi-paragraph history (FT-04).
        var open = filled.applications[0]
        open.notes.append(Note(text: "Call with HR, very friendly.\n\nThey want the portfolio as one PDF, max 10 MB.",
                               date: Date(timeIntervalSince1970: 1_794_300_000)))
        for (name, appearance) in [("row-expanded-light", NSAppearance.Name.aqua), ("row-expanded-dark", .darkAqua)] {
            let row = Row(app: .constant(open), expanded: true, onEdit: {}, onDelete: {})
                .padding(24).frame(width: 820).background(Theme.page).foregroundStyle(Theme.ink)
            try render(row, size: NSSize(width: 820, height: 560), appearance: appearance,
                       to: out.appendingPathComponent("\(name).png"))
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: out.appendingPathComponent("dark.png").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: out.appendingPathComponent("row-expanded-dark.png").path))
    }

    private func render(_ view: some View, size: NSSize, appearance: NSAppearance.Name, to file: URL) throws {
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: size)
        let window = NSWindow(contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: appearance)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        let rep = try XCTUnwrap(host.bitmapImageRepForCachingDisplay(in: host.bounds))
        host.cacheDisplay(in: host.bounds, to: rep)
        try XCTUnwrap(rep.representation(using: .png, properties: [:])).write(to: file)
    }
}
