// Generated using TezosGen

import TezosSwift

struct ContractMethodInvocation {
    private let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?

    init(send: @escaping (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?) {
        self.send = send
    }

    func send(from: Wallet, amount: TezToken, operationFees: OperationFees? = nil, completion: @escaping RPCCompletion<String>) -> Cancelable? {
        self.send(from, amount, operationFees, completion)
    }
}
