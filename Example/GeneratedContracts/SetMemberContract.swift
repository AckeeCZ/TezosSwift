// Generated using TezosGen
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct SetMemberContractBox {
    fileprivate let tezosClient: TezosClient
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient
       self.at = at
    }
    /**
     Call SetMemberContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(_ param1: String) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: String = param1
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<SetMemberContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of SetMemberContract
struct SetMemberContractStatus: Decodable {
    /// Balance of SetMemberContract in Tezos
    let balance: Tez
    /// Is contract spendable
    let spendable: Bool
    /// SetMemberContract's manager address
    let manager: String
    /// SetMemberContract's delegate
    let delegate: StatusDelegate
    /// SetMemberContract's current operation counter
    let counter: Int
    /// SetMemberContract's storage
    let storage:SetMemberContractStatusStorage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decode(SetMemberContractStatusStorage.self, forKey: .storage)
    }
}
/**
 SetMemberContract's storage with specified args.
 **Important:**
 Args are in the order of how they are specified in the Tezos structure tree
*/
struct SetMemberContractStatusStorage: Decodable {
    let arg1: [String]
	let arg2: Bool?

    public init(from decoder: Decoder) throws {
        let tezosElement = try decoder.singleValueContainer().decode(TezosPair<[String], Bool?>.self)

        self.arg1 = tezosElement.first.sorted()
		self.arg2 = tezosElement.second
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call SetMemberContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func setMemberContract(at: String) -> SetMemberContractBox {
        return SetMemberContractBox(tezosClient: self, at: at)
    }
}