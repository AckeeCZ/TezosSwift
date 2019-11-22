//
//  XCTestCase+Extra.swift
//  UnitTests
//
//  Created by Marek Fořt on 11/22/19.
//  Copyright © 2019 Ackee. All rights reserved.
//

import Foundation
import XCTest

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

