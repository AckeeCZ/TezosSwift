// Generated using TezosGen
// swiftlint:disable file_length

import Foundation
import TezosSwift

/// Struct for function currying
struct BytesContractBox {
    fileprivate let tezosClient: TezosClient
    fileprivate let at: String

    fileprivate init(tezosClient: TezosClient, at: String) {
       self.tezosClient = tezosClient
       self.at = at
    }
    /**
     Call BytesContract with specified params.
     **Important:**
     Params are in the order of how they are specified in the Tezos structure tree
    */
    func call(_ param1: Data) -> ContractMethodInvocation {
        let send: (_ from: Wallet, _ amount: TezToken, _ operationFees: OperationFees?, _ completion: @escaping RPCCompletion<String>) -> Cancelable?
        let input: Data = param1
        send = { from, amount, operationFees, completion in
            self.tezosClient.call(amount: amount, to: self.at, from: from, input: input, operationFees: operationFees, completion: completion)
        }

        return ContractMethodInvocation(send: send)
    }

    /// Call this method to obtain contract status data
    @discardableResult
    func status(completion: @escaping RPCCompletion<BytesContractStatus>) -> Cancelable? {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
        return tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }
}

/// Status data of BytesContract
struct BytesContractStatus: Decodable {
    /// BytesContract's storage
    let storage: Data

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let scriptContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try scriptContainer.nestedContainer(keyedBy: StorageKeys.self, forKey: .storage).decodeRPC(Data.self)
    }
}

extension TezosClient {
    /**
     This function returns type that you can then use to call BytesContract specified by address.

     - Parameter at: String description of desired address.

     - Returns: Callable type to send Tezos with.
    */
    func bytesContract(at: String) -> BytesContractBox {
        return BytesContractBox(tezosClient: self, at: at)
    }
}