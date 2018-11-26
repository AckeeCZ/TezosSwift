// Generated using TezosGen 
// swiftlint:disable file_length

struct TestContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }
    func call(param1: Int) -> ContractMethodInvocation {
		let input: Int = param1
        let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<TestContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

struct TestContractStatus: Decodable {
    let balance: Tez
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: Int 

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

		let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script).nestedContainer(keyedBy: TezosTypeKeys.self, forKey: .storage)
        self.storage = try storageContainer.decodeRPC(Int.self, forKey: .int)
    }
}

extension TezosClient {
    func testContract(at: String) -> TestContractBox {
        return TestContractBox(tezosClient: self, at: at)
    }
}
