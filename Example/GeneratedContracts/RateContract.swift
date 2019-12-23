// Generated using TezosGen
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct RateContractBox {
    fileprivate let tezosClient: TezosClient
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient
       self.at = at
    }
    /**
     Call RateContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func end() -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        send = { from, amount, operationFees, completion in
            self.tezosClient.call(amount: amount, to: self.at, from: from, operationName: "end", operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /**
     Call RateContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func vote(_ param1: [String: Int]) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: TezosMap<String, Int> = TezosMap(pairs: param1.map { TezosPair(first: $0.0, second: $0.1) })
        send = { from, amount, operationFees, completion in
            self.tezosClient.call(amount: amount, to: self.at, from: from, input: input, operationName: "vote", operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<RateContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of RateContract
struct RateContractStatus: Decodable {
    /// RateContract's storage
    let storage: RateContractStatusStorage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decode(RateContractStatusStorage.self, forKey: .storage)
    }
}
/**
 RateContract's storage with specified args.
 **Important:**
 Args are in the order of how they are specified in the Tezos structure tree
*/
struct RateContractStatusStorage: Decodable {
    let ballot: [String: Ballot]
	let hasEnded: Bool
	let master: String
	let totalNumberOfVotes: Int
	let voters: [String: Int]
	let votesPerVoter: Int

    public init(from decoder: Decoder) throws {
        let tezosElement = try decoder.singleValueContainer().decode(TezosPair<TezosPair<TezosPair<TezosPair<TezosPair<TezosMap<String, TezosPair<String, Int>>, Bool>, String>, Int>, TezosMap<String, Int>>, Int>.self)
        self.ballot = tezosElement.first.first.first.first.first.pairs.reduce([:], { var mutable = $0; mutable[$1.first] = Ballot($1.second); return mutable })
		self.hasEnded = tezosElement.first.first.first.first.second
		self.master = tezosElement.first.first.first.second
		self.totalNumberOfVotes = tezosElement.first.first.second
		self.voters = tezosElement.first.second.pairs.reduce([:], { var mutable = $0; mutable[$1.first] = $1.second; return mutable })
		self.votesPerVoter = tezosElement.second
    }
}

struct Ballot {
    let candidateName: String
	let numberOfVotes: Int
    
    init(_ tezosElement: TezosPair<String, Int>) {
        self.candidateName = tezosElement.first
		self.numberOfVotes = tezosElement.second
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call RateContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func rateContract(at: String) -> RateContractBox {
        return RateContractBox(tezosClient: self, at: at)
    }
}