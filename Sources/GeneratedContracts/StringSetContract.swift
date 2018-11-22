// Generated using TezosGen 
// swiftlint:disable file_length

struct StringSetContractBox: ContractBoxing {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String
    typealias Status = StringSetContractStatus

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }
    func call(param1: Set<String>) -> ContractMethodInvocation {
		let input: Set<String> = param1 
        let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<StringSetContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

struct StringSetContractStatus: Decodable {
    let balance: Tez
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: Set<String> 

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.decodeRPC(Set<String>.self, forKey: .storage)
    }
}

extension TezosClient {
    func stringSetContract(at: String) -> StringSetContractBox {
        return StringSetContractBox(tezosClient: self, at: at)
    }
}

protocol ContractBoxing {
    associatedtype Status: Decodable
    func status(completion: @escaping RPCCompletion<Status>)
}
