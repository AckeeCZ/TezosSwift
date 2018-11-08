//
//  ContractStatus.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/1/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

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

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script).nestedContainer(keyedBy: TezosTypeKeys.self, forKey: .storage)
        self.storage = try storageContainer.decodeRPC(Int.self, forKey: .int)
        try super.init(from: decoder)
    }
}

struct TezosPair<T: Decodable, U: Decodable> {
    typealias First = T
    typealias Second = U
    let first: First
    let second: Second
}

private enum StorageKeys: String, CodingKey {
    case prim
    case args
}

extension KeyedDecodingContainer {
    func decodeRPC<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T : Decodable {
        let value: Any
        switch type {
        case is Int.Type:
            value = try decodeRPC(Int.self, forKey: key)
        case is Bool.Type:
            value = try decodeRPC(Bool.self, forKey: key)
        default:
            value = try decode(T.self, forKey: key)
            print(value)
        }
        guard let unwrappedValue = value as? T else {
            throw TezosError.unsupportedTezosType
        }
        return unwrappedValue
    }

    func decodeRPC(_ type: Int.Type, forKey key: K) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        guard let decodedInt = Int(intString) else { throw DecodingError.dataCorrupted(context) }
        return decodedInt
    }

    func decodeRPC(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let boolString = try decode(String.self, forKey: key)
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        switch boolString {
        case "True": return true
        case "False": return false
        default: throw DecodingError.dataCorrupted(context)
        }
    }
}

extension TezosPair: Decodable {
    init(from decoder: Decoder) throws {

        var container = try decoder.container(keyedBy: StorageKeys.self).nestedUnkeyedContainer(forKey: .args)
        let firstContainer = try container.nestedContainer(keyedBy: StorageKeys.self)
        let secondContainer = try container.nestedContainer(keyedBy: StorageKeys.self)

        let firstPrimaryType = try firstContainer.decode(String.self, forKey: .prim).self
        if firstPrimaryType == "Pair" {
            self.first = try firstContainer.decode(First.self, forKey: .args)
        } else {
            self.first = try firstContainer.decodeRPC(First.self, forKey: .prim).self
        }

        let secondPrimaryType = try secondContainer.decode(String.self, forKey: .prim).self
        if secondPrimaryType == "Pair" {
            self.second = try secondContainer.decode(Second.self, forKey: .args)
        } else {
            self.second = try secondContainer.decodeRPC(Second.self, forKey: .prim).self
        }
    }
}

public struct PairContractStatusStorage: Decodable {
    let arg1: Bool
    let arg2: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StorageKeys.self)
        var argsContainer = try container.nestedUnkeyedContainer(forKey: .args)

        let tezosPair = try argsContainer.decode(TezosPair<Bool, Bool>.self)

        self.arg1 = tezosPair.first
        self.arg2 = tezosPair.second
    }

}

public class PairContractStatus: ContractStatus {
    let storage: PairContractStatusStorage

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try storageContainer.decode(PairContractStatusStorage.self, forKey: .storage)

        try super.init(from: decoder)
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
