//
//  ContractStatus.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/1/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

public enum ContractStatusKeys: String, CodingKey {
    case balance = "balance"
    case spendable = "spendable"
    case manager = "manager"
    case delegate = "delegate"
    case counter = "counter"
    case script = "script"
    case storage = "storage"
}

public enum StorageKeys: String, CodingKey {
    case int
    case string
    case prim
    case args
    case bytes
}

public enum TezosPrimaryType: String, Codable {
    case some = "Some"
    case none = "None"
    case pair = "Pair"
    case map = "Elt"
    case right = "Right"
    case left = "Left"
}

public struct ContractStatus: Decodable {
    public let balance: Tez
    public let spendable: Bool
    public let manager: String
    public let delegate: StatusDelegate
    public let counter: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(Tez.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)
    }
}
