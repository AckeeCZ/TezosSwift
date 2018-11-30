// Generated using TezosGen 
// swiftlint:disable file_length

import TezosSwift
import Foundation

struct OrSwapContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    func call(param1: Bool?, param2: String?) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ completion: @escaping RPCCompletion<String>) -> Void
        guard let tezosOr1 = TezosOr(left: param1, right: param2) else { 
            send = { from, amount, completion in
                completion(.failure(.orError))
            }
            return ContractMethodInvocation(send: send)
        }
        
		let input: TezosOr<Bool, String> = tezosOr1 
        send = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<OrSwapContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

struct OrSwapContractStatus: Decodable {
    let balance: Tez
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: OrSwapContractStatusStorage 

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decode(OrSwapContractStatusStorage.self, forKey: .storage)
    }
}

struct OrSwapContractStatusStorage: Decodable {
	let arg1: String?
	let arg2: Bool?

    public init(from decoder: Decoder) throws {
        let tezosElement = try decoder.singleValueContainer().decode(TezosOr<String, Bool>.self)

		self.arg1 = tezosElement.left
		self.arg2 = tezosElement.right
    }
}

extension TezosClient {
    func orSwapContract(at: String) -> OrSwapContractBox {
        return OrSwapContractBox(tezosClient: self, at: at)
    }
}
