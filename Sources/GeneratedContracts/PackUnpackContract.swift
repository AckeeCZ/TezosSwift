// Generated using TezosGen 
// swiftlint:disable file_length

import Foundation

struct PackUnpackContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    func call(param1: String, param2: [Int], param3: Set<UInt>, param4: Data) -> ContractMethodInvocation {
        let input: TezosPair<TezosPair<TezosPair<String, [Int]>, Set<UInt>>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: param1, second: param2), second: param3), second: param4)
        let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void = { from, amount, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

	func status(completion: @escaping RPCCompletion<ContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

extension TezosClient {
    func packUnpackContract(at: String) -> PackUnpackContractBox {
        return PackUnpackContractBox(tezosClient: self, at: at)
    }
}
