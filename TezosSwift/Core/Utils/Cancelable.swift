//
//  Cancelable.swift
//  cortez-ios
//
//  Created by Steve Sanches on 14/02/2019.
//  Copyright © 2019 Steve Sanches. All rights reserved.
//

public protocol Cancelable {
	func cancel()
}

public struct AnyCancelable: Cancelable {
	
	public typealias Body = () -> Void
	
	private let body: Body
	
	public init(_ body: @escaping Body) {
		self.body = body
	}
	
	public func cancel() {
		body()
	}
}
