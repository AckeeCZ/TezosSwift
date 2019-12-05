// Generated using TezosGen
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct ParameterPairContractBox {
    fileprivate let tezosClient: TezosClient
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient
       self.at = at
    }
    /**
     Call ParameterPairContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(first: Bool, second: Bool) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: TezosPair<Bool, Bool> = TezosPair(first: first, second: second)
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<ParameterPairContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of ParameterPairContract
struct ParameterPairContractStatus: Decodable {
    /// Balance of ParameterPairContract in Tezos
    let balance: Tez
    /// Is contract spendable
    let spendable: Bool
    /// ParameterPairContract's manager address
    let manager: String
    /// ParameterPairContract's delegate
    let delegate: StatusDelegate
    /// ParameterPairContract's current operation counter
    let counter: Int
    /// ParameterPairContract's storage
    let storage:Bool?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.nestedContainer(keyedBy: StorageKeys.self, forKey: .storage).decodeRPC(Bool?.self)
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call ParameterPairContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func parameterPairContract(at: String) -> ParameterPairContractBox {
        return ParameterPairContractBox(tezosClient: self, at: at)
    }
}