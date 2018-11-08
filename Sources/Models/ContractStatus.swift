//
//  ContractStatus.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/1/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

protocol Contract {
    var balance: TezosBalance { get }
    var spendable: Bool { get }
    var manager: String { get }
//    var delegate: StatusDelegate { get }
}

protocol ContractStorage: Contract {
    associatedtype Storage: Decodable
}

//extension ContractStorage {
//    func decode() {
//        self.spendable = true 
//    }
//}

private enum ContractStatusKeys: String, CodingKey {
    case balance = "balance"
    case spendable = "spendable"
    case manager = "manager"
    case delegate = "delegate"
    case counter = "counter"
    case script = "script"
    case storage = "storage"
}

private enum TezosTypeKeys: String, CodingKey {
    case int = "int"
    case string = "string"
}

public struct StatusDelegate: Codable {
    let setable: Bool
    let value: String?
}

public class IntContractStatus: ContractStatus {
    let storage: Int
    // let storage: (String, Tuple(String, Tuple(Int, String)))

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script).nestedContainer(keyedBy: TezosTypeKeys.self, forKey: .storage)
        self.storage = try storageContainer.decodeRPC(Int.self, forKey: .int)
        try super.init(from: decoder)
    }
}

extension KeyedDecodingContainer {
    func decodeRPC(_ type: Int.Type, forKey key: K) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        guard let decodedInt = Int(intString) else { throw DecodingError.dataCorrupted(context) }
        return decodedInt
    }
}

public class ContractStatus: Decodable {
    let balance: TezosBalance
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(TezosBalance.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)
    }
}
