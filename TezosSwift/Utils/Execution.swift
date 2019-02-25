//
//  Execution.swift
//  TezosSwift
//
//  Created by Steve Sanches on 19/02/2019.
//  Copyright © 2019 Ackee. All rights reserved.
//

import Result

public final class Execution<Value, Error: Swift.Error & CancelProtocol>: Cancelable {

	public typealias Completion = AnyCompletable<Value, Error>.Completion
	
	public var trigger: Cancelable?
	
	public enum State {
		case executing(Completion), canceling(Completion), completed
	}
	public private(set) var state: Atomic<State>

	public init(_ completion: @escaping Completion) {
		state = Atomic(.executing(completion))
	}

	public func complete(with result: Result<Value, Error>) {
		state.reduce {
			switch $0 {
			case let .executing(completion):
				completion(result)
			case let .canceling(completion):
				completion(.failure(Error.cancel))
			case .completed:
				return $0
			}
			return .completed
		}
	}

	public func cancel() {
		state.reduce {
			guard case let .executing(completion) = $0 else { return $0 }
			trigger?.cancel()
			return .canceling(completion)
		}
	}
}
