// Generated using TezosGen 
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct OptionalPairBoolContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    /**
     Call OptionalPairBoolContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(param1: Bool, param2: Bool) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ completion: @escaping RPCCompletion<String>) -> Void
		let input: TezosPair<Bool, Bool> = TezosPair(first: param1, second: param2) 
        send = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
	func status(completion: @escaping RPCCompletion<OptionalPairBoolContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of OptionalPairBoolContract
struct OptionalPairBoolContractStatus: Decodable {
    /// Balance of OptionalPairBoolContract in Tezos
    let balance: Tez
    /// Is contract spendable
    let spendable: Bool
    /// OptionalPairBoolContract's manager address
    let manager: String
    /// OptionalPairBoolContract's delegate
    let delegate: StatusDelegate
    /// OptionalPairBoolContract's current operation counter 
    let counter: Int
    /// OptionalPairBoolContract's storage
    let storage: OptionalPairBoolContractStatusStorage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decode(OptionalPairBoolContractStatusStorage.self, forKey: .storage)
    }
}

/**
 OptionalPairBoolContract's storage with specified args.
 **Important:**
 Args are in the order of how they are specified in the Tezos structure tree
*/
struct OptionalPairBoolContractStatusStorage: Decodable {
	let arg1: Bool?
	let arg2: Bool?

    public init(from decoder: Decoder) throws {
        let tezosElement = try decoder.singleValueContainer().decode(TezosPair<Bool, Bool>?.self)

		self.arg1 = tezosElement?.first
		self.arg2 = tezosElement?.second
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call OptionalPairBoolContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func optionalPairBoolContract(at: String) -> OptionalPairBoolContractBox {
        return OptionalPairBoolContractBox(tezosClient: self, at: at)
    }
}
