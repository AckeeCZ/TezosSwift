import XCTest
import TezosSwift
@testable import TezosSwift_Example

class OperationTest: XCTestCase {
	public func testRequiresReveal() {
		let OperationRequiringReveal = Operation(source: "tz1abc", kind: .delegation)
		XCTAssertTrue(OperationRequiringReveal.requiresReveal)

		let OperationNotRequiringReveal = Operation(source: "tz1abc", kind: .reveal)
		XCTAssertFalse(OperationNotRequiringReveal.requiresReveal)
	}
}

