// Generated using TezosGen 
// swiftlint:disable file_length

struct OptionalPairBoolContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }
    func call(param1: Bool, param2: Bool) -> ContractMethodInvocation {
		let input: TezosPair<Bool, Bool> = TezosPair(first: param1, second: param2) 
        let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<OptionalPairBoolContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

struct OptionalPairBoolContractStatus: Decodable {
    let balance: Tez
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
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

struct OptionalPairBoolContractStatusStorage: Decodable {
	let arg1: Bool?
	let arg2: Bool?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StorageKeys.self)
        let tezosElement = try container.decode(TezosPair<Bool?, Bool?>.self, forKey: .args)

		self.arg1 = tezosElement.first
		self.arg2 = tezosElement.second
    }
}

extension TezosClient {
    func optionalPairBoolContract(at: String) -> OptionalPairBoolContractBox {
        return OptionalPairBoolContractBox(tezosClient: self, at: at)
    }
}
