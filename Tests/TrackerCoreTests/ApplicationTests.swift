import XCTest
@testable import TrackerCore

final class ApplicationTests: XCTestCase {
    func testToApplyKeepsNoDate() {
        let a = Application(company: "Acme")
        XCTAssertEqual(a.status, .toApply)
        XCTAssertNil(a.sentDate)
    }

    func testSentDateSetOnce() {
        var a = Application(company: "Acme")
        let first = Date(timeIntervalSince1970: 1_000_000)
        a.setStatus(.sent, on: first)
        XCTAssertEqual(a.sentDate, first)
        a.setStatus(.reply, on: Date(timeIntervalSince1970: 2_000_000))
        XCTAssertEqual(a.sentDate, first)
    }

    func testCounts() {
        let apps = Status.allCases.map { status -> Application in
            var a = Application(company: status.title)
            a.setStatus(status)
            return a
        }
        let c = Counts(apps)
        XCTAssertEqual([c.total, c.sent, c.replies, c.interviews], [6, 5, 4, 1])
    }

    func testStatusTitles() {
        XCTAssertEqual(Status.allCases.map(\.title),
                       ["To apply", "Sent", "Got a reply", "Interview", "Rejected", "Offer"])
    }
}
