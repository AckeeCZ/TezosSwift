//
//  ExecutionTests.swift
//  UnitTests
//
//  Created by Steve Sanches on 20/02/2019.
//  Copyright © 2019 Ackee. All rights reserved.
//

import XCTest
import TezosSwift
import Result

class ExecutionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testExectionCompleteSuccess() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.complete(with: .success(4))
		XCTAssertEqual(result?.value, 4)
	}
    func testExectionCompleteFailure() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.complete(with: .failure(.dummy))
		XCTAssertEqual(result?.error, .dummy)
    }
	
	func testExecutionCancelSuccess() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.cancel()
		execution.complete(with: .success(4))
		XCTAssertEqual(result?.error, .userCancel)
	}
	func testExecutionCancelFailure() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.cancel()
		execution.complete(with: .failure(.dummy))
		XCTAssertEqual(result?.error, .userCancel)
	}
	
	func testExecutionCancelTrigger() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		let spy = CancelableSpy()
		execution.trigger = spy
		execution.cancel()
		execution.complete(with: .success(4))
		XCTAssertTrue(spy.cancelCalled)
		XCTAssertEqual(result?.error, .userCancel)
	}
	
	enum FakeError: Error, CancelProtocol, ErrorConvertible, Equatable {
		
		case dummy, userCancel
		
		static var cancel: FakeError = .userCancel
		
		static func error(from error: Error) -> FakeError {
			return .dummy
		}
	}
	
	final class CancelableSpy: Cancelable {
		
		var cancelCalled = false
		
		func cancel() {
			cancelCalled = true
		}
	}
}