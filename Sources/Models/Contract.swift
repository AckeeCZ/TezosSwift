////
////  Contract.swift
////  TezosSwift
////
////  Created by Marek Fořt on 11/15/18.
////  Copyright © 2018 Keefer Taylor. All rights reserved.
////
//
//import Foundation
//
//struct ContractMethodInvocation {
//    private let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void
//
//    init(send: @escaping (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void) {
//        self.send = send
//    }
//
//    func send(from: Wallet, amount: Tez, completion: @escaping RPCCompletion<String>) {
//        self.send(from, amount, completion)
//    }
//}
//
//struct TestContractBox {
//    // TODO: Testing - "TezosClienting"
//    fileprivate let tezosClient: TezosClient
//    fileprivate let at: String
//
//    init(tezosClient: TezosClient, at: String) {
//        self.tezosClient = tezosClient
//        self.at = at
//    }
//
//    func call(param1: Bool, param2: Bool) -> ContractMethodInvocation {
//        let input: TezosPair<Bool, Bool> = TezosPair(first: param1, second: param2)
//        let send: (_ from: Wallet, _ amount: Tez, _ completion: @escaping RPCCompletion<String>) -> Void = { from, amount, completion in
//            self.tezosClient.send(amount: amount, to: self.at, from: from, input: input, completion: completion)
//        }
//
//        return ContractMethodInvocation(send: send)
//    }
//
//    public func status(completion: @escaping RPCCompletion<IntContractStatus>) {
//        let endpoint = "/chains/main/blocks/head/context/contracts/" + at
//        tezosClient.sendRPC(endpoint: endpoint, method: .get, completion: completion)
//    }
//}
//
//extension TezosClient {
//    // TODO: Replace this with address
//    func testContract(at: String) -> TestContractBox {
//        return TestContractBox(tezosClient: self, at: at)
//    }
//}
