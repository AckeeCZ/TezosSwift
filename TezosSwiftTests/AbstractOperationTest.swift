import XCTest
import TezosKit

class OperationTest: XCTestCase {
	public func testRequiresReveal() {
		let OperationRequiringReveal = Operation(source: "tz1abc", kind: .delegation)
		XCTAssertTrue(OperationRequiringReveal.requiresReveal)

		let OperationNotRequiringReveal = Operation(source: "tz1abc", kind: .reveal)
		XCTAssertFalse(OperationNotRequiringReveal.requiresReveal)
	}

	public func testDictionaryRepresentation() {
		let source = "tz1abc"
		let kind: OperationKind = .delegation
		let fee = TezosBalance(balance: 1)
		let gasLimit = TezosBalance(balance: 2)
		let storageLimit = TezosBalance(balance: 3)

		let Operation = Operation(source: source, kind: kind, fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
		let dictionary = Operation.dictionaryRepresentation

		XCTAssertNotNil(dictionary["source"])
		XCTAssertEqual(dictionary["source"], source)

		XCTAssertNotNil(dictionary["kind"])
		XCTAssertEqual(dictionary["kind"], kind.rawValue)

		XCTAssertNotNil(dictionary["fee"])
		XCTAssertEqual(dictionary["fee"], fee.rpcRepresentation)

		XCTAssertNotNil(dictionary["gas_limit"])
		XCTAssertEqual(dictionary["gas_limit"], gasLimit.rpcRepresentation)

		XCTAssertNotNil(dictionary["storage_limit"])
		XCTAssertEqual(dictionary["storage_limit"], storageLimit.rpcRepresentation)
	}
}
