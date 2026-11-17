import XCTest
@testable import TrackerCore

final class StoreTests: XCTestCase {
    func tempDir() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    func testRoundtrip() {
        let dir = tempDir()
        let a = Store(directory: dir)
        a.applications.append(Application(company: "Acme", role: "Designer", link: "https://example.com"))
        a.applications[0].setStatus(.sent)
        a.applications[0].notes = [Note(text: "Sent portfolio.\n\nSecond paragraph.")]
        a.applications[0].nextStep = "Follow up"
        a.applications[0].nextStepDate = Date(timeIntervalSince1970: 1_800_000_000)
        a.applications.append(Application(company: "Beta"))
        let b = Store(directory: dir)
        XCTAssertEqual(b.applications, a.applications)
        XCTAssertEqual(b.applications.count, 2)
        XCTAssertNil(b.loadProblem)
    }

    func testEveryChangeIsWritten() throws {
        let store = Store(directory: tempDir())
        store.applications = [Application(company: "Acme")]
        store.applications[0].nextStep = "typed"
        let onDisk = try Store.decoder.decode([Application].self, from: Data(contentsOf: store.fileURL))
        XCTAssertEqual(onDisk.first?.nextStep, "typed")
        XCTAssertNil(store.saveError)
    }

    func testBackupCreatedOnLoad() throws {
        let dir = tempDir()
        Store(directory: dir).applications = [Application(company: "Acme")]
        let store = Store(directory: dir)
        let backup = try Data(contentsOf: dir.appendingPathComponent("applications.backup.json"))
        XCTAssertEqual(backup, try Data(contentsOf: store.fileURL))
    }

    func testUnreadableFileIsKept() throws {
        let dir = tempDir()
        let first = Store(directory: dir)
        first.applications = [Application(company: "Acme")]
        _ = Store(directory: dir)  // creates the backup from the good file
        try Data("garbage".utf8).write(to: first.fileURL)

        let store = Store(directory: dir)
        XCTAssertNotNil(store.loadProblem)
        XCTAssertTrue(store.applications.isEmpty)
        let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
        let aside = try XCTUnwrap(files.first { $0.hasPrefix("applications.unreadable-") })
        XCTAssertEqual(try String(contentsOf: dir.appendingPathComponent(aside), encoding: .utf8), "garbage")
        let backup = try Store.decoder.decode([Application].self,
                                              from: Data(contentsOf: dir.appendingPathComponent("applications.backup.json")))
        XCTAssertEqual(backup.first?.company, "Acme")
    }

    /// A file written by v0.1.0 (single `note` string) loads; the note becomes the first dated entry.
    func testV010FileMigrates() throws {
        let dir = tempDir()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let v010 = """
        [{"company":"Acme","createdAt":"2026-11-17T10:00:00Z","id":"6F9619FF-8B86-D011-B42D-00C04FC964FF",
          "link":"","note":"Called HR.","role":"Designer","sentDate":"2026-11-17T11:00:00Z","status":"sent"},
         {"company":"Beta","createdAt":"2026-11-17T12:00:00Z","id":"7F9619FF-8B86-D011-B42D-00C04FC964FF",
          "link":"","note":"  ","role":"","status":"to-apply"}]
        """
        try Data(v010.utf8).write(to: dir.appendingPathComponent("applications.json"))
        let store = Store(directory: dir)
        XCTAssertNil(store.loadProblem)
        XCTAssertEqual(store.applications.map(\.notes.count), [1, 0])
        XCTAssertEqual(store.applications[0].notes[0].text, "Called HR.")
        XCTAssertEqual(store.applications[0].notes[0].date, store.applications[0].createdAt)
        XCTAssertEqual(store.applications[0].nextStep, "")
        XCTAssertNil(store.applications[0].nextStepDate)
    }
}
