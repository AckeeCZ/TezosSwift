//
//  Atomic.swift
//  cortez-ios
//
//  Created by Steve Sanches on 19/02/2019.
//  Copyright © 2019 Steve Sanches. All rights reserved.
//

import Foundation

public struct Atomic<Value> {
	
	private var value: Value
	
	private let semaphore = DispatchSemaphore(value: 1)
	
	public init(_ value: Value) {
		self.value = value
	}
	
	public mutating func reduce(with transition: (Value) -> Value) {
		semaphore.wait()
		value = transition(value)
		semaphore.signal()
	}
}

extension Atomic {
	public mutating func update(with value: Value) {
		reduce { _ in value }
	}
}
