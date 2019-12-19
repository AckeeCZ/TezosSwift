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
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: TezosPair<Bool, Bool> = TezosPair(first: param1, second: param2)
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<OptionalPairBoolContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of OptionalPairBoolContract
struct OptionalPairBoolContractStatus: Decodable {
    /// OptionalPairBoolContract's storage
    let storage: OptionalPairBoolContractStatusStorage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
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
        let container = try decoder.container(keyedBy: StorageKeys.self)
        var nestedContainer = try? container.nestedUnkeyedContainer(forKey: .args)
        let tezosElement = try nestedContainer?.decode(TezosPair<Bool, Bool>?.self)
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