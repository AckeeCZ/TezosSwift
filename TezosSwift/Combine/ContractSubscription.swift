//
//  ContractSubscription.swift
//  TezosSwift-Combine
//
//  Created by Marek Fořt on 11/22/19.
//  Copyright © 2019 Ackee. All rights reserved.
//

import Foundation
import Combine
import TezosSwift

class ContractSubscription<S: Subscriber, Output: Decodable>: Subscription where S.Input == Output, S.Failure == TezosError {
    private let send: SendMethod<Output>
    private var hasValue = true
    private var cancelable: Cancelable?
    private var cancellable: Cancellable?
    private var subscriber: S
    
    init(subscriber: S, send: @escaping SendMethod<Output>) {
        self.subscriber = subscriber
        self.send = send
    }
    
    func request(_ demand: Subscribers.Demand) {
        guard hasValue else { return }
        cancellable = Future { [weak self] promise in
            self?.cancelable = self?.send(promise)
        }.sink(receiveCompletion: { [weak self] in
            self?.subscriber.receive(completion: $0)
        }, receiveValue: { [weak self] in
            _ = self?.subscriber.receive($0)
        })
    }
    
    func cancel() {
        cancelable?.cancel()
        cancellable?.cancel()
    }
}
