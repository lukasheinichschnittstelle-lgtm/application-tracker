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
        a.applications[0].note = "Sent portfolio."
        a.applications.append(Application(company: "Beta"))
        let b = Store(directory: dir)
        XCTAssertEqual(b.applications, a.applications)
        XCTAssertEqual(b.applications.count, 2)
        XCTAssertNil(b.loadProblem)
    }

    func testEveryChangeIsWritten() throws {
        let store = Store(directory: tempDir())
        store.applications = [Application(company: "Acme")]
        store.applications[0].note = "typed"
        let onDisk = try Store.decoder.decode([Application].self, from: Data(contentsOf: store.fileURL))
        XCTAssertEqual(onDisk.first?.note, "typed")
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
}
