//
//  TezosViewController.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/2/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import UIKit
import TezosSwift

class TezosViewController: UIViewController {
    let tezosClient = TezosClient(remoteNodeURL: URL(string: "https://rpcalpha.tzbeta.net/")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire pill praise"
        let wallet = Wallet(mnemonic: mnemonic)!

//        tezosClient.chainHead { result in
//            switch result {
//            case .success(let chainHead):
//                print(chainHead.chainId)
//                print(chainHead.protocol)
//            case .failure(let error):
//                print("Calling chain head failed with error: \(error)")
//            }
//        }
//
//        tezosClient.balance(of: "KT1DwASQY1uTEkzWUShbeQJfKpBdb2ugsE5k", completion: { result in
//            switch result {
//            case .success(let balance):
//                print(balance.humanReadableRepresentation)
//            case .failure(let error):
//                print("Getting balance failed with error: \(error)")
//            }
//        })
//
//        tezosClient.send(amount: Tez(1), to: "tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ", from: wallet, completion: { result in
//            switch result {
//            case .success(let transactionHash):
//                print("Transaction succeeded with: \(transactionHash)")
//            case .failure(let error):
//                print("Sending Tezos failed with error: \(error)")
//            }
//        })

        tezosClient.natSetContract(at: "KT1DwASQY1uTEkzWUShbeQJfKpBdb2ugsE5k").call([UInt(1), UInt(2), UInt(3)]).send(from: wallet, amount: Tez.zero, completion: { result in
            switch result {
            case .failure(let error):
                print("Call failed with error: \(error)")
            case .success(let operationHash):
                print("Call succeeded with \(operationHash)")
            }
        })
    }
}
