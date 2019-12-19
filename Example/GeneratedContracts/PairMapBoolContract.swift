// Generated using TezosGen
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct PairMapBoolContractBox {
    fileprivate let tezosClient: TezosClient
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient
       self.at = at
    }
    /**
     Call PairMapBoolContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(param1: [String: Int], param2: Bool) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: TezosPair<TezosMap<String, Int>, Bool> = TezosPair(first: TezosMap(pairs: param1.map { TezosPair(first: $0.0, second: $0.1) }), second: param2)
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<PairMapBoolContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of PairMapBoolContract
struct PairMapBoolContractStatus: Decodable {
    /// PairMapBoolContract's storage
    let storage: PairMapBoolContractStatusStorage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decode(PairMapBoolContractStatusStorage.self, forKey: .storage)
    }
}
/**
 PairMapBoolContract's storage with specified args.
 **Important:**
 Args are in the order of how they are specified in the Tezos structure tree
*/
struct PairMapBoolContractStatusStorage: Decodable {
    let arg1: [String: Int]
	let arg2: Bool

    public init(from decoder: Decoder) throws {
        let tezosElement = try decoder.singleValueContainer().decode(TezosPair<TezosMap<String, Int>, Bool>.self)
        self.arg1 = tezosElement.first.pairs.reduce([:], { var mutable = $0; mutable[$1.first] = $1.second; return mutable })
		self.arg2 = tezosElement.second
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call PairMapBoolContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func pairMapBoolContract(at: String) -> PairMapBoolContractBox {
        return PairMapBoolContractBox(tezosClient: self, at: at)
    }
}