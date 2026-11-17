import Foundation

public enum Status: String, Codable, CaseIterable, Identifiable {
    case toApply = "to-apply", sent, reply, interview, rejected, offer

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .toApply: "To apply"
        case .sent: "Sent"
        case .reply: "Got a reply"
        case .interview: "Interview"
        case .rejected: "Rejected"
        case .offer: "Offer"
        }
    }
}

public struct Application: Codable, Identifiable, Equatable {
    public var id = UUID()
    public var company: String
    public var role: String
    public var link: String
    public var status: Status = .toApply
    public var sentDate: Date?
    public var notes: [Note] = []
    public var nextStep = ""
    public var nextStepDate: Date?
    public var createdAt = Date.now.wholeSeconds

    public init(company: String, role: String = "", link: String = "") {
        self.company = company
        self.role = role
        self.link = link
    }

    /// Leaving "To apply" stamps the sent date once; later changes keep it (as in the mock-up).
    public mutating func setStatus(_ new: Status, on date: Date = .now) {
        status = new
        if new != .toApply && sentDate == nil { sentDate = date.wholeSeconds }
    }

    /// The next step is due on its day and stays highlighted until it is changed or cleared.
    public func isDue(on now: Date = .now) -> Bool {
        guard let day = nextStepDate else { return false }
        return Calendar.current.startOfDay(for: day) <= Calendar.current.startOfDay(for: now)
    }

    private enum Legacy: String, CodingKey { case note }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        company = try c.decode(String.self, forKey: .company)
        role = try c.decode(String.self, forKey: .role)
        link = try c.decode(String.self, forKey: .link)
        status = try c.decode(Status.self, forKey: .status)
        sentDate = try c.decodeIfPresent(Date.self, forKey: .sentDate)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        notes = try c.decodeIfPresent([Note].self, forKey: .notes) ?? []
        nextStep = try c.decodeIfPresent(String.self, forKey: .nextStep) ?? ""
        nextStepDate = try c.decodeIfPresent(Date.self, forKey: .nextStepDate)
        // v0.1.0 kept one free-text note; it becomes the first entry, dated when the application was added.
        let old = try decoder.container(keyedBy: Legacy.self).decodeIfPresent(String.self, forKey: .note) ?? ""
        if !old.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notes.insert(Note(text: old, date: createdAt), at: 0)
        }
    }
}

public struct Note: Codable, Identifiable, Equatable {
    public var id = UUID()
    public var date: Date
    public var text: String

    public init(text: String, date: Date = .now) {
        self.text = text
        self.date = date.wholeSeconds
    }
}

public struct Counts: Equatable {
    public let total: Int, sent: Int, replies: Int, interviews: Int

    public init(_ apps: [Application]) {
        func count(_ s: Set<Status>) -> Int { apps.filter { s.contains($0.status) }.count }
        total = apps.count
        sent = apps.count - count([.toApply])
        // A reply is any answer from the company, including rejections and offers (T6).
        replies = count([.reply, .interview, .rejected, .offer])
        interviews = count([.interview])
    }
}

extension Date {
    /// The file stores ISO 8601 without fractions, so in-memory dates match what is saved.
    var wholeSeconds: Date { Date(timeIntervalSince1970: timeIntervalSince1970.rounded(.down)) }
}
