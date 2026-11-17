import Foundation
import Observation

@Observable
public final class Store {
    public var applications: [Application] = [] { didSet { save() } }
    public private(set) var loadProblem: String?
    public private(set) var saveError: String?
    public let fileURL: URL
    @ObservationIgnored private var readOnly = false

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    public static var defaultDirectory: URL {
        URL.applicationSupportDirectory.appendingPathComponent("Application Tracker", isDirectory: true)
    }

    public var directory: URL { fileURL.deletingLastPathComponent() }

    public init(directory: URL = Store.defaultDirectory) {
        fileURL = directory.appendingPathComponent("applications.json")
        load()
    }

    private func load() {
        let fm = FileManager.default
        guard fm.fileExists(atPath: fileURL.path) else { return }
        do {
            let apps = try Self.decoder.decode([Application].self, from: Data(contentsOf: fileURL))
            // Back up only a file we could read, so a broken file never replaces the last good backup.
            let backup = directory.appendingPathComponent("applications.backup.json")
            try? fm.removeItem(at: backup)
            try? fm.copyItem(at: fileURL, to: backup)
            applications = apps
        } catch {
            let stamp = DateFormatter()
            stamp.dateFormat = "yyyyMMdd-HHmmss"
            let aside = directory.appendingPathComponent("applications.unreadable-\(stamp.string(from: .now)).json")
            do {
                try fm.moveItem(at: fileURL, to: aside)
                loadProblem = "Your data file could not be read. It was kept as \(aside.lastPathComponent) next to the new one."
            } catch {
                readOnly = true  // never overwrite a file we could not read or move
                loadProblem = "Your data file could not be read and was left untouched. Changes will not be saved."
            }
        }
    }

    private func save() {
        guard !readOnly else { saveError = "Not saved: the existing data file could not be read."; return }
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try Self.encoder.encode(applications).write(to: fileURL, options: .atomic)
            saveError = nil
        } catch {
            saveError = "Could not save: \(error.localizedDescription)"
        }
    }
}
