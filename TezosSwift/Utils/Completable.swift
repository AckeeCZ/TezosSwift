//
//  Completable.swift
//  cortez-ios
//
//  Created by Steve Sanches on 14/02/2019.
//  Copyright © 2019 Steve Sanches. All rights reserved.
//

import Foundation
import Result

public protocol CancelProtocol: Error {
	static var cancel: Self { get }
}

public protocol Completable {
	
	associatedtype Value
	associatedtype Error: Swift.Error & CancelProtocol
	
	typealias Completion = (Result<Value, Self.Error>) -> Void
	
	func execute(_ completion: @escaping Completion) -> Cancelable?
}

public extension Completable {
	
	typealias OnSuccess = (Value) -> Void
	typealias OnFailure = (Error) -> Void
	
	func execute(onSuccess: @escaping OnSuccess, onFailure: @escaping OnFailure) -> Cancelable? {
		return execute {
			switch $0 {
			case let .success(value): onSuccess(value)
			case let .failure(error): onFailure(error)
			}
		}
	}
}

public struct AnyCompletable<Value, Error: Swift.Error & CancelProtocol>: Completable {
	
	public typealias Body = (@escaping Completion) -> Cancelable?
	
	private let body: Body
	
	public init(_ body: @escaping Body) {
		self.body = body
	}
	
	public func execute(_ completion: @escaping (Result<Value, Error>) -> Void) -> Cancelable? {
		let execution = Execution<Value, Error>(completion)
		execution.trigger = body(execution.complete)
		return execution
	}
}

public extension AnyCompletable {
	init<T>(_ base: T) where T: Completable, Value == T.Value, Error == T.Error {
		self.init(base.execute)
	}
}

public extension Result where Error: ErrorConvertible {
	func map<T>(_ transform: (Value) throws -> T) -> Result<T, Error> {
		do {
			switch self {
			case let .success(value):
				return .success(try transform(value))
			case let .failure(error):
				throw error
			}
		} catch let error as Error {
			return .failure(error)
		} catch {
			return .failure(.error(from: error))
		}
	}
}

public extension Completable where Error: ErrorConvertible {
	func map<T>(_ transform: @escaping (Value) throws -> T) -> AnyCompletable<T, Error> {
		return AnyCompletable { completion in
			self.execute { completion($0.map(transform)) }
		}
	}
}

public extension Completable where Value : Completable, Error == Value.Error {
	func flatten() -> AnyCompletable<Value.Value, Value.Error> {
		return AnyCompletable { completion in
			var cancelable = Atomic<Cancelable?>(nil)
			cancelable.update(
				with: self.execute(
					onSuccess: { cancelable.update(with: $0.execute(completion)) },
					onFailure: { completion(.failure($0)) }
				)
			)
			return AnyCancelable { cancelable.reduce { $0?.cancel(); return nil } }
		}
	}
}

public extension Completable where Error: ErrorConvertible {
	func flatMap<T>(_ transform: @escaping (Value) throws -> T) -> AnyCompletable<T.Value, Error>
		where T : Completable, Error == T.Error {
			return map(transform).flatten()
	}
}

public extension Completable {
	func on(_ queue: DispatchQueue) -> AnyCompletable<Value, Error> {
		return AnyCompletable { completion in
			self.execute { result in queue.async { completion(result) } }
		}
	}
}

