//
//  ExecutionTests.swift
//  UnitTests
//
//  Created by Steve Sanches on 20/02/2019.
//  Copyright © 2019 Ackee. All rights reserved.
//

import XCTest
import TezosSwift

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
        XCTAssertSuccessResult(result, 4)
	}
    func testExectionCompleteFailure() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.complete(with: .failure(.dummy))
        XCTAssertFailureResult(result, .dummy)
    }
	
	func testExecutionCancelSuccess() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.cancel()
		execution.complete(with: .success(4))
        XCTAssertFailureResult(result, .userCancel)
	}
	func testExecutionCancelFailure() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		execution.cancel()
		execution.complete(with: .failure(.dummy))
		XCTAssertFailureResult(result, .userCancel)
	}
	
	func testExecutionCancelTrigger() {
		var result: Result<Int, FakeError>?
		let execution = Execution { result = $0 }
		let spy = CancelableSpy()
		execution.trigger = spy
		execution.cancel()
		execution.complete(with: .success(4))
		XCTAssertTrue(spy.cancelCalled)
		XCTAssertFailureResult(result, .userCancel)
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

extension XCTestCase {
    func XCTAssertFailureResult<Error: Swift.Error & Equatable, T>(_ result: Result<T, Error>?, _ error: Error, file: StaticString = #file, line: UInt = #line) {
        guard let result = result else {
            XCTFail("Result is equal to nil", file: file, line: line)
            return
        }
        switch result {
        case let .failure(resultError):
            XCTAssertEqual(error, resultError, file: file, line: line)
        case .success:
            XCTFail("Result was successful - expected failure", file: file, line: line)
        }
    }
    
    func XCTAssertSuccessResult<Error: Swift.Error, T: Equatable>(_ result: Result<T, Error>?, _ expectedValue: T, file: StaticString = #file, line: UInt = #line) {
        guard let result = result else {
            XCTFail("Result is equal to nil", file: file, line: line)
            return
        }
        switch result {
        case .failure:
            XCTFail("Result is a failure - expected success", file: file, line: line)
        case let .success(value):
            XCTAssertEqual(expectedValue, value)
        }
    }
}
