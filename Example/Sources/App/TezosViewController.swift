//
//  TezosViewController.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/2/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import UIKit
import os
import TezosSwift

class TezosViewController: UIViewController {
    let tezosClient = TezosClient(remoteNodeURL: URL(string: "https://rpcalpha.tzbeta.net/")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire pill burger"
        let wallet = Wallet(mnemonic: mnemonic)!

        tezosClient.chainHead { result in
            switch result {
            case .success(let chainHead):
                print(chainHead.chainId)
                print(chainHead.protocol)
            case .failure(let error):
                print("Calling chain head failed with error: \(error)")
            }
        }

        tezosClient.balance(of: "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA", completion: { result in
            switch result {
            case .success(let balance):
                print(balance.humanReadableRepresentation)
            case .failure(let error):
                print("Getting balance failed with error: \(error)")
            }
        })

        tezosClient.send(amount: Tez(1), to: "tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ", from: wallet, completion: { result in
            switch result {
            case .success(let transactionHash):
                print(transactionHash)
            case .failure(let error):
                print("Sending Tezos failed with error: \(error)")
            }
        })
    }
}
