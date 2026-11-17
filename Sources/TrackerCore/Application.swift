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
    public var note = ""
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
