//
//  RPCDecodable.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/26/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

protocol RPCDecodable: Decodable {}
extension Int: RPCDecodable {}
extension UInt: RPCDecodable {}
extension Bool: RPCDecodable {}
extension String: RPCDecodable {}
extension Data: RPCDecodable {}
extension Tez: RPCDecodable {}
extension Mutez: RPCDecodable {}
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

    func decodeRPC(_ type: Mutez.Type) throws -> Mutez {
        return try decode(Mutez.self, forKey: .int)
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
        case is Mutez.Type, is Mutez?.Type:
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
        let primaryType = try container.decodeIfPresent(String.self, forKey: .prim).self
        if primaryType == "Pair" || primaryType == "Some" || primaryType == "Elt" {
            // TODO: Check different ways of outputs for some (optional lists?)
            var mutableSomeContainer = try container.nestedUnkeyedContainer(forKey: .args)
            let someContainer = try mutableSomeContainer.nestedContainer(keyedBy: StorageKeys.self)
            return (try someContainer.decodeRPC(T.self), mutableSomeContainer)
        } else {
            return (try container.decodeRPC(T.self), nil)
        }
    }
}
