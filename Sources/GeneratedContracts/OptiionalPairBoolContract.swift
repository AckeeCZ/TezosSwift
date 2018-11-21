// Generated using TezosGen 
// swiftlint:disable file_length

struct OptiionalPairBoolContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }
    func call(param1: Bool?, param2: Bool?) -> ContractMethodInvocation {
		let input: TezosPair<Bool?, Bool?> = TezosPair(first: param1, second: param2) 
        let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<OptiionalPairBoolContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

struct OptiionalPairBoolContractStatus: Decodable {
    let balance: Tez
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: TezosPair<Bool?, Bool?> 

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script).nestedContainer(keyedBy: StorageKeys.self, forKey: .storage)
        self.storage = try storageContainer.decodeRPC(TezosPair<Bool?, Bool?>.self)
    }
}

extension TezosClient {
    func optiionalPairBoolContract(at: String) -> OptiionalPairBoolContractBox {
        return OptiionalPairBoolContractBox(tezosClient: self, at: at)
    }
}
