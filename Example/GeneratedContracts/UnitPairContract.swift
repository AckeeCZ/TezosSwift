// Generated using TezosGen
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct UnitPairContractBox {
    fileprivate let tezosClient: TezosClient
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient
       self.at = at
    }
    /**
     Call UnitPairContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(_ param1: String) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: TezosPair<Never?, String> = TezosPair(first: nil, second: param1)
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<UnitPairContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of UnitPairContract
struct UnitPairContractStatus: Decodable {
    /// Balance of UnitPairContract in Tezos
    let balance: Tez
    /// Is contract spendable
    let spendable: Bool
    /// UnitPairContract's manager address
    let manager: String
    /// UnitPairContract's delegate
    let delegate: StatusDelegate
    /// UnitPairContract's current operation counter
    let counter: Int
    /// UnitPairContract's storage
    let storage: UnitPairContractStatusStorage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decode(UnitPairContractStatusStorage.self, forKey: .storage)
    }
}
/**
 UnitPairContract's storage with specified args.
 **Important:**
 Args are in the order of how they are specified in the Tezos structure tree
*/
struct UnitPairContractStatusStorage: Decodable {
    let arg1: Never?
	let arg2: String

    public init(from decoder: Decoder) throws {        let tezosElement = try decoder.singleValueContainer().decode(TezosPair<Never?, String>.self)
        self.arg1 = tezosElement.first
		self.arg2 = tezosElement.second
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call UnitPairContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func unitPairContract(at: String) -> UnitPairContractBox {
        return UnitPairContractBox(tezosClient: self, at: at)
    }
}