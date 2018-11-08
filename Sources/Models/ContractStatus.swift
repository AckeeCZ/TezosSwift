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

public enum TezosTypeKeys: String, CodingKey {
    case int = "int"
    case string = "string"
}

public enum StorageKeys: String, CodingKey {
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

public struct IntContractStatus: Decodable {
    let balance: TezosBalance
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(TezosBalance.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script).nestedContainer(keyedBy: TezosTypeKeys.self, forKey: .storage)
        self.storage = try storageContainer.decodeRPC(Int.self, forKey: .int)
    }
}

public struct PairContractStatus: Decodable {
    let balance: TezosBalance
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int
    let storage: PairContractStatusStorage

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(TezosBalance.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)

        let storageContainer = try container.nestedContainer(keyedBy: ContractStatusKeys.self, forKey: .script)
        self.storage = try storageContainer.decode(PairContractStatusStorage.self, forKey: .storage)
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

public struct ContractStatus: Decodable {
    let balance: TezosBalance
    let spendable: Bool
    let manager: String
    let delegate: StatusDelegate
    let counter: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        self.balance = try container.decode(TezosBalance.self, forKey: .balance)
        self.spendable = try container.decode(Bool.self, forKey: .spendable)
        self.manager = try container.decode(String.self, forKey: .manager)
        self.delegate = try container.decode(StatusDelegate.self, forKey: .delegate)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)
    }
}
