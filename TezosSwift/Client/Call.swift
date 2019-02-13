//
//  Call.swift
//  BigInt
//
//  Created by Steve Sanches on 13/02/2019.
//

import Foundation
import Result

public protocol Cancelable {
	func cancel()
}

extension URLSessionTask: Cancelable {}

public struct AnyCancelable: Cancelable {
	
	public typealias Body = () -> Void
	
	private let body: Body
	
	public init(_ body: @escaping Body) {
		self.body = body
	}
	public init(_ base: Cancelable) {
		self.init(base.cancel)
	}
	
	public func cancel() {
		body()
	}
}

public protocol CustomErrorConvertible {
	init(_ error: Error)
}

public protocol Call {
	
	associatedtype Value
	associatedtype Error: Swift.Error & CustomErrorConvertible

	typealias Completion = (Result<Value, Error>) -> Void
	
	func perform(_ completion: @escaping Completion) -> Cancelable?
}

public struct AnyCall<Value, Error: Swift.Error & CustomErrorConvertible>: Call {
	
	public typealias Body = (@escaping Completion) -> Cancelable?
	
	private let body: Body
	
	public init(_ body: @escaping Body) {
		self.body = body
	}
	public init<T>(_ base: T) where T : Call, Value == T.Value, Error == T.Error {
		self.init(base.perform)
	}
	
	public func perform(_ completion: @escaping (Result<Value, Error>) -> Void) -> Cancelable? {
		return body(completion)
	}
}

extension TezosError: CustomErrorConvertible {
	public init(_ error: Error) {
		if let error = error as? TezosError {
			self = error
			return
		}
		self = .unknown(message: error.localizedDescription)
	}
}

extension Call {
	public func flatMap<T>(_ transform: @escaping (Value) throws -> T) -> AnyCall<T.Value, T.Error> where T : Call, Error == T.Error {
		return AnyCall<T.Value, T.Error> { completion in
			let semaphore = DispatchSemaphore(value: 1)
			var canceling = false
			var cancelable: Cancelable?
			cancelable = self.perform { result in
				semaphore.wait(); defer { semaphore.signal() }
				if canceling {
					completion(.failure(T.Error(TezosError.cancel)))
					return
				}
				do {
					switch result {
					case let .success(value):
						let nextCall = try transform(value)
						cancelable = nextCall.perform(completion)
					case let .failure(error):
						throw error
					}
				} catch let error as T.Error {
					completion(.failure(error))
				} catch {
					completion(.failure(T.Error(error)))
				}
			}
			return AnyCancelable {
				semaphore.wait(); defer { semaphore.signal() }
				if canceling { return }
				canceling = true
				cancelable?.cancel()
			}
		}
	}
}
