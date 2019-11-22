//
//  CompletableTests.swift
//  UnitTests
//
//  Created by Steve Sanches on 19/02/2019.
//  Copyright © 2019 Ackee. All rights reserved.
//

import XCTest
import TezosSwift

class CompletableTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testExecuteSuccess() {
		var result: Result<Int, FakeError>?
		_ = AnyCompletable<Int, FakeError> {
			$0(.success(4))
			return nil // not cancelable
		}.execute {
			result = $0
		}
        XCTAssertSuccessResult(result, 4)
	}
	
	func testExecuteFailure() {
		var result: Result<Int, FakeError>?
		_ = AnyCompletable<Int, FakeError> {
			$0(.failure(.dummy))
			return nil // not cancelable
		}.execute {
			result = $0
		}
        XCTAssertFailureResult(result, .dummy)
	}
	
    func testMapSuccess() {
		var result: Result<Int, FakeError>?
		let string = "Hello, world!"
		_ = AnyCompletable<String, FakeError> {
			$0(.success(string))
			return nil // not cancelable
		}.map {
			$0.count
		}.execute {
			result = $0
		}
        XCTAssertSuccessResult(result, string.count)
    }
	
	func testMapFailure() {
		var result: Result<Int, FakeError>?
		let string = "Hello, world!"
		_ = AnyCompletable<String, FakeError> {
			$0(.success(string))
			return nil // not cancelable
		}.map { _ in
			throw FakeError.dummy
		}.execute {
			result = $0
		}
        XCTAssertFailureResult(result, .dummy)
	}
	
	func testFlattenSuccess() {
		var result: Result<Int, FakeError>?
		let completable = AnyCompletable<Int, FakeError> {
			$0(.success(4))
			return nil
		}
		_ = AnyCompletable<AnyCompletable<Int, FakeError>, FakeError> {
			$0(.success(completable))
			return nil
		}.flatten().execute {
			result = $0
		}
        XCTAssertSuccessResult(result, 4)
	}
	
	func testFlattenSinkFailure() {
		var result: Result<Int, FakeError>?
		let completable = AnyCompletable<Int, FakeError> {
			$0(.failure(.dummy))
			return nil
		}
		_ = AnyCompletable<AnyCompletable<Int, FakeError>, FakeError> {
			$0(.success(completable))
			return nil
		}.flatten().execute {
			result = $0
		}
        XCTAssertFailureResult(result, .dummy)
	}
	
	func testFlattenGeneratorFailure() {
		var result: Result<Int, FakeError>?
		_ = AnyCompletable<AnyCompletable<Int, FakeError>, FakeError> {
			$0(.failure(.dummy))
			return nil
		}.flatten().execute {
			result = $0
		}
        XCTAssertFailureResult(result, .dummy)
	}
	
	func testCancel() {
		var result: Result<Int, FakeError>?
		let expectation = self.expectation(description: #function)
		let cancelable = AnyCompletable<Int, FakeError> { completion in
			DispatchQueue.main.async {
				completion(.success(4))
				expectation.fulfill()
			}
			return nil
		}.execute {
			result = $0
		}
		cancelable?.cancel()
		wait(for: [expectation], timeout: 2)
		XCTAssertFailureResult(result, .userCancel)
	}
	
	enum FakeError: Error, CancelProtocol, ErrorConvertible, Equatable {
		
		case dummy
		case userCancel

		static var cancel: FakeError = .userCancel

		static func error(from error: Error) -> FakeError {
			return .dummy
		}
	}
}
