// Generated using TezosGen 
// swiftlint:disable file_length

import Foundation
import TezosSwift

struct PackUnpackContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    func call(param1: String, param2: [Int], param3: [UInt], param4: Data) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Void
		let input: TezosPair<TezosPair<TezosPair<String, [Int]>, [UInt]>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: param1, second: param2), second: param3.sorted()), second: param4) 
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
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
