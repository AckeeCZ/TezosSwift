//
//  TezosPair.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/8/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

protocol RPCCodable: RPCEncodable, RPCDecodable {}

struct TezosPair<T: RPCCodable, U: RPCCodable> {
    typealias First = T
    typealias Second = U
    let first: First
    let second: Second

    init?(first: First?, second: Second?) {
        guard let first = first, let second = second else { return nil }
        self.first = first
        self.second = second
    }

    init(first: First, second: Second) {
        self.first = first
        self.second = second
    }
}

extension TezosPair: RPCDecodable {
    init(from decoder: Decoder) throws {
        var mutableContainer = try decoder.unkeyedContainer()
        // Hold container (can't decode it twice)
        let storageContainer: UnkeyedDecodingContainer?
        (first, storageContainer) = try mutableContainer.decodeElement()
        (second, _) = try mutableContainer.decodeElement(previousContainer: storageContainer)
    }
}

extension TezosPair: RPCEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StorageKeys.self)
        try container.encode("Pair", forKey: .prim)
        var argsContainer = container.nestedUnkeyedContainer(forKey: .args)
        try argsContainer.encodeRPC(first)
        try argsContainer.encodeRPC(second)
    }

    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try container.encode(self, forKey: key)
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        try container.encode(self)
    }
}

protocol RPCEncodable: Encodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws
    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws
}

extension Array: RPCEncodable where Element: Encodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedUnkeyedContainer(forKey: key)
        try forEach { try nestedContainer.encodeRPC($0) }
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedUnkeyedContainer()
        try forEach { try nestedContainer.encodeRPC($0) }
    }
}

extension Set: RPCEncodable where Element: Encodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedUnkeyedContainer(forKey: key)
        try forEach { try nestedContainer.encodeRPC($0) }
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedUnkeyedContainer()
        try forEach { try nestedContainer.encodeRPC($0) }
    }
}

extension Int: RPCEncodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self, forKey: key)
        try nestedContainer.encode("\(self)", forKey: .int)
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self)
        try nestedContainer.encode("\(self)", forKey: .int)
    }
}

extension UInt: RPCEncodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self, forKey: key)
        try nestedContainer.encode("\(self)", forKey: .int)
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self)
        try nestedContainer.encode("\(self)", forKey: .int)
    }
}

extension String: RPCEncodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self, forKey: key)
        try nestedContainer.encode(self, forKey: .string)
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self)
        try nestedContainer.encode(self, forKey: .string)
    }
}

extension Bool: RPCEncodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self, forKey: key)
        try nestedContainer.encode("\(self)".capitalized, forKey: .prim)
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self)
        try nestedContainer.encode("\(self)".capitalized, forKey: .prim)
    }
}

extension Data: RPCEncodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self, forKey: key)
        try nestedContainer.encode(self, forKey: .bytes)
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self)
        try nestedContainer.encode(self, forKey: .bytes)
    }
}

extension Optional: RPCEncodable where Wrapped: RPCEncodable {
    func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        var nestedContainer = container.nestedContainer(keyedBy: StorageKeys.self, forKey: key)
        switch self {
        case .none:
            try nestedContainer.encode("None", forKey: .prim)
        case .some(let value):
            try nestedContainer.encode("Some", forKey: .prim)
            var argsContainer = nestedContainer.nestedUnkeyedContainer(forKey: .args)
            try argsContainer.encodeRPC(value)
        }
    }

    func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {

    }
}

extension KeyedEncodingContainer {
    mutating func encodeRPC<T: Encodable>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws {
        if let unwrappedValue = value as? RPCEncodable {
            try unwrappedValue.encodeRPC(in: &self, forKey: key)
        } else {
            try encode(value, forKey: key)
        }
    }
}

extension UnkeyedEncodingContainer {
    func encodingError(_ value: Any) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding failed")
        return EncodingError.invalidValue(value, context)
    }

    // TODO: Encode if present when params optionals!
    mutating func encodeRPC<T: Encodable>(_ value: T) throws {
        if let unwrappedValue = value as? RPCEncodable {
            try unwrappedValue.encodeRPC(in: &self)
        } else {
            try encode(value)
        }
    }
}

protocol RPCDecodable: Decodable {}
extension Int: RPCDecodable {}
extension UInt: RPCDecodable {}
extension Bool: RPCDecodable {}
extension String: RPCDecodable {}
extension Data: RPCDecodable {}
extension Set : RPCDecodable where Element : RPCDecodable {}
extension Array : RPCDecodable where Element : RPCDecodable {}
extension Optional: RPCDecodable where Wrapped: RPCDecodable {}

extension UnkeyedDecodingContainer {
    func corruptedError() -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        return DecodingError.dataCorrupted(context)
    }

    mutating func decodeRPC<T: RPCDecodable>(_ type: Set<T>.Type) throws -> Set<T> {
        var set: Set<T> = []
        while !isAtEnd {
            let container = try nestedContainer(keyedBy: StorageKeys.self)
            let element  = try container.decodeRPC(T.self)
            set.insert(element)
        }
        return set
    }

    mutating func decodeRPC<T: RPCDecodable>(_ type: [T].Type) throws -> [T] {
        var array: [T] = []
        while !isAtEnd {
            let container = try nestedContainer(keyedBy: StorageKeys.self)
            let element  = try container.decodeRPC(T.self)
            array.append(element)
        }
        return array
    }
}

extension KeyedDecodingContainerProtocol {
    // MARK: Decoding
    func decryptionError() -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        return DecodingError.dataCorrupted(context)
    }

    func decodeRPC(_ type: Int.Type, forKey key: Key) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        guard let decodedInt = Int(intString) else { throw decryptionError() }
        return decodedInt
    }

    func decodeRPC(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        let boolString = try decode(String.self, forKey: key)
        switch boolString {
        case "True": return true
        case "False": return false
        default: throw decryptionError()
        }
    }

    func decodeRPC(_ type: Data.Type, forKey key: Key) throws -> Data {
        let dataString = try decode(String.self, forKey: key)
        guard let decodedData = dataString.data(using: .utf8) else { throw decryptionError() }
        return decodedData
    }

    func decodeRPC<T: RPCDecodable>(_ type: Set<T>.Type, forKey key: Key) throws -> Set<T> {
        var arrayContainer = try nestedUnkeyedContainer(forKey: key)
        return try arrayContainer.decodeRPC(type)
    }

    func decodeRPC<T: RPCDecodable>(_ type: [T].Type, forKey key: Key) throws -> [T] {
        var arrayContainer = try nestedUnkeyedContainer(forKey: key)
        return try arrayContainer.decodeRPC(type)
    }

    func decodeRPC<T: RPCDecodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try decode(T.self, forKey: key)
    }

    func decodeRPC<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try decode(T.self, forKey: key)
    }
}

extension KeyedDecodingContainerProtocol where Key == StorageKeys {

    func decodeRPC<T>(_ type: T?.Type) throws -> T? where T : RPCDecodable {
        let tezosOptional = try decode(TezosOptional.self, forKey: .prim)
        guard tezosOptional == .some else { return nil }
        var optionalContainer = try nestedUnkeyedContainer(forKey: .args)
        let nestedContainer = try optionalContainer.nestedContainer(keyedBy: StorageKeys.self)
        return try nestedContainer.decodeRPC(T.self)
    }

    func decodeRPC(_ type: Int.Type) throws -> Int {
        return try decodeRPC(Int.self, forKey: .int)
    }

    func decodeRPC(_ type: Bool.Type) throws -> Bool {
        return try decodeRPC(Bool.self, forKey: .prim)
    }

    func decodeRPC(_ type: String.Type) throws -> String {
        return try decode(String.self, forKey: .string)
    }

    func decodeRPC(_ type: Data.Type) throws -> Data {
        return try decodeRPC(Data.self, forKey: .bytes)
    }

    func decodeRPC<T: Decodable>(_ type: T.Type) throws -> T {
        return try decode(type, forKey: .prim)
    }

    func decodeRPC<T: RPCDecodable>(_ type: T.Type) throws -> T {
        // TODO: Would be nice to do this generically, thus supporting right away all RPCDecodable types
        let value: Any
        switch type {
        case is Int.Type, is Int?.Type:
            value = try decodeRPC(Int.self)
        case is String.Type, is String?.Type:
            value = try decodeRPC(String.self)
        case is Bool.Type, is Bool?.Type:
            value = try decodeRPC(Bool.self)
        case is Data.Type, is Data?.Type:
            value = try decodeRPC(Data.self)
        default:
            value = try decode(type, forKey: .prim)
        }
        guard let unwrappedValue = value as? T else { throw decryptionError() }
        return unwrappedValue
    }
}

extension UnkeyedDecodingContainer {
    mutating func decodeElement<T: RPCDecodable & Collection>(previousContainer: UnkeyedDecodingContainer? = nil) throws -> (T, UnkeyedDecodingContainer?) where T.Element: RPCDecodable & Hashable {
        var arrayContainer = try nestedUnkeyedContainer()
        var array: [T.Element] = []
        while !arrayContainer.isAtEnd {
            let container = try arrayContainer.nestedContainer(keyedBy: StorageKeys.self)
            let element = try container.decodeRPC(T.Element.self)
            array.append(element)
        }

        if let finalArray = array as? T {
            return (finalArray, nil)
        }

        guard let set = Set<T.Element>(array) as? T else { throw TezosError.unsupportedTezosType }

        return (set, nil)
    }

    mutating func decodeElement<T: RPCDecodable & Collection>(previousContainer: UnkeyedDecodingContainer? = nil) throws -> (T, UnkeyedDecodingContainer?) where T.Element: RPCDecodable {
        var arrayContainer = try nestedUnkeyedContainer()
        var array: [T.Element] = []
        while !arrayContainer.isAtEnd {
            let container = try arrayContainer.nestedContainer(keyedBy: StorageKeys.self)
            let element = try container.decodeRPC(T.Element.self)
            array.append(element)
        }

        guard let finalArray = array as? T else { throw TezosError.unsupportedTezosType }
        return (finalArray, nil)
    }

    mutating func decodeElement<T: RPCDecodable>(previousContainer: UnkeyedDecodingContainer? = nil) throws -> (T, UnkeyedDecodingContainer?) {
        if var currentContainer = previousContainer {
            let container = try currentContainer.nestedContainer(keyedBy: StorageKeys.self)
            return (try container.decodeRPC(T.self), currentContainer)
        }
        let container = try nestedContainer(keyedBy: StorageKeys.self)
        let primaryType = try container.decode(String.self, forKey: .prim).self
        if primaryType == "Pair" || primaryType == "Some" {
            // TODO: Check different ways of outputs for some (optional lists?)
            var mutableSomeContainer = try container.nestedUnkeyedContainer(forKey: .args)
            let someContainer = try mutableSomeContainer.nestedContainer(keyedBy: StorageKeys.self)
            return (try someContainer.decodeRPC(T.self), mutableSomeContainer)
        } else {
            return (try container.decodeRPC(T.self), nil)
        }
    }
}
