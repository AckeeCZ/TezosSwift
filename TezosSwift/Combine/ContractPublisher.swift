import Combine
import TezosSwift

typealias SendMethod<Output: Decodable> = (@escaping RPCCompletion<Output>) -> Cancelable?

public struct ContractPublisher<O: Decodable>: Publisher {
    public typealias Output = O
    public typealias Failure = TezosError
    
    private let send: SendMethod<Output>
    
    public init(send: @escaping SendMethod<Output>) {
        self.send = send
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = ContractSubscription(subscriber: subscriber, send: send)
        subscriber.receive(subscription: subscription)
    }
}
