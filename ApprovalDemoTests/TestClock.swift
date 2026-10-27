import Foundation
import Synchronization

final class TestClock: Sendable {
    private let date = Mutex(Date(timeIntervalSince1970: 0))

    func now() -> Date {
        date.withLock { $0 }
    }

    func advance(by seconds: TimeInterval) {
        date.withLock { $0.addTimeInterval(seconds) }
    }
}
