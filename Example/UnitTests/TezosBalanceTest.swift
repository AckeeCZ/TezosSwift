import XCTest
import TezosSwift
@testable import TezosSwift_Example

class TezTest: XCTestCase {
	public func testHumanReadableRepresentation() {
		let balanceFromNumber = Tez(3.50)

		XCTAssertEqual(balanceFromNumber.humanReadableRepresentation, "3.500000")
	}

	public func testRPCRepresentation() {
		let balanceFromNumber = Tez(3.50)

		XCTAssertEqual(balanceFromNumber.rpcRepresentation, "3500000")
	}
}
