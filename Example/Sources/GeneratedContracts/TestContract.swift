// Generated using TezosGen 
// swiftlint:disable file_length

import Foundation
import TezosSwift

struct TestContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    /**
     Call TestContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(param1: Int) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ completion: @escaping RPCCompletion<String>) -> Void
		let input: Int = param1 
        send = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
	func status(completion: @escaping RPCCompletion<TestContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of TestContract
struct TestContractStatus: Decodable {
    /// Balance of TestContract in Tezos
    let balance: Tez
    /// Is contract spendable
    let spendable: Bool
    /// TestContract's manager address
    let manager: String
    /// TestContract's delegate
    let delegate: StatusDelegate
    /// TestContract's current operation counter 
    let counter: Int
    /// TestContract's storage
    let storage: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.nestedContainer(keyedBy: StorageKeys.self, forKey: .storage).decodeRPC(Int.self)
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call TestContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func testContract(at: String) -> TestContractBox {
        return TestContractBox(tezosClient: self, at: at)
    }
}
