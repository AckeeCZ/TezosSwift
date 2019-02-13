//
//  NetworkSession.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/30/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

// Taken from: https://www.swiftbysundell.com/posts/mocking-in-swift
/// Protocol for network testing
public protocol NetworkSession {
	@discardableResult
    func loadData(with urlRequest: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancelable?
}

extension URLSession: NetworkSession {
	@discardableResult
    public func loadData(with urlRequest: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancelable? {
        let task = dataTask(with: urlRequest) { (data, response, error) in
            completionHandler(data, response, error)
        }

        task.resume()
		return task
    }
}
