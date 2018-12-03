// Generated using TezosGen 
// swiftlint:disable file_length

import Foundation
import TezosSwift

struct AddressContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    func call(param1: String) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ completion: @escaping RPCCompletion<String>) -> Void
		let input: String = param1 
        send = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<AddressContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

struct AddressContractStatus: Decodable {
    let balance: Tez
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.nestedContainer(keyedBy: StorageKeys.self, forKey: .storage).decodeRPC(String.self)
    }
}

extension TezosClient {
    func addressContract(at: String) -> AddressContractBox {
        return AddressContractBox(tezosClient: self, at: at)
    }
}
