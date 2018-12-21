// Generated using TezosGen 
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct PackUnpackContractBox {
    fileprivate let tezosClient: TezosClient 
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient 
       self.at = at 
    }

    /**
     Call PackUnpackContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(param1: String, param2: [Int], param3: [UInt], param4: Data) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Void
		let input: TezosPair<TezosPair<TezosPair<String, [Int]>, [UInt]>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: param1, second: param2), second: param3.sorted()), second: param4) 
        send = { from, amount, operationFees, completion in
            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
	func status(completion: @escaping RPCCompletion<ContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call PackUnpackContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func packUnpackContract(at: String) -> PackUnpackContractBox {
        return PackUnpackContractBox(tezosClient: self, at: at)
    }
}
