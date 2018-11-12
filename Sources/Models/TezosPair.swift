//
//  TezosPair.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/8/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

struct TezosPair<T: Decodable, U: Decodable> {
    typealias First = T
    typealias Second = U
    let first: First
    let second: Second
}

extension UnkeyedDecodingContainer {
    func corruptedError() -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        return DecodingError.dataCorrupted(context)
    }

    mutating func decodeElement<T: Decodable>(previousContainer: UnkeyedDecodingContainer? = nil) throws -> (T, UnkeyedDecodingContainer?) {
        if var arrayContainer = try? nestedUnkeyedContainer() {
            // Can I generically access generic's element type?
            let genericArray: [Any] = try arrayContainer.decodeRPC([Any].self)
            guard let finalArray = genericArray as? T else { throw TezosError.unsupportedTezosType }
            return (finalArray, nil)
        } else {
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

    // TODO: Use array decoding from decodeElement() function
    mutating func decodeRPC<T>(_ type: [T].Type) throws -> [T] {
        var genericArray: [Any] = []

        while !isAtEnd {
            let container = try nestedContainer(keyedBy: StorageKeys.self)
            // TODO: Maybe refactor it to decodeRPC ? (what about prims, though)
            let value: Any
            if container.contains(.int) {
                value = try container.decodeRPC(Int.self)
            } else if container.contains(.string) {
                value = try container.decodeRPC(String.self)
            } else {
                value = try container.decodeRPC(Bool.self)
            }
            genericArray.append(value)
        }
        guard let finalArray = genericArray as? [T] else { throw corruptedError() }
        return finalArray
    }
}

extension TezosPair: Decodable {
    init(from decoder: Decoder) throws {
        var mutableContainer = try decoder.unkeyedContainer()
        // Hold container (can't decode it twice)
        let storageContainer: UnkeyedDecodingContainer?
        (first, storageContainer) = try mutableContainer.decodeElement()
        (second, _) = try mutableContainer.decodeElement(previousContainer: storageContainer)
    }
}

extension KeyedEncodingContainer {
    // MARK: Encoding

    func encodingError(_ value: Any) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding failed")
        return EncodingError.invalidValue(value, context)
    }

    // TODO: Rewrite error
    mutating func encodeRPC<T: Encodable>(_ value: T) throws {
        // TODO: Handle nil values
        guard var container = self as? KeyedEncodingContainer<StorageKeys> else { throw encodingError(value) }
        switch value.self {
        case is Int:
            guard let unwrappedValue = value as? Int else { throw encodingError(value) }
            try container.encode("\(unwrappedValue)", forKey: .int)
            //        case is String:
            //            value = try container.decode(String.self, forKey: .string)
            //        case is Bool:
        //            value = try container.decodeRPC(Bool.self, forKey: .prim)
        default:
            try container.encode(value, forKey: .prim)
        }

        guard let containerWithKeys = container as? KeyedEncodingContainer<K> else { throw encodingError(container) }
        self = containerWithKeys
    }

    mutating func encodeRPC(_ value: Int, forKey key: KeyedEncodingContainer<K>.Key) throws {

    }
}

extension KeyedDecodingContainer {

    // MARK: Decoding

    func decryptionError() -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        return DecodingError.dataCorrupted(context)
    }

    func decodeRPC<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard let container = self as? KeyedDecodingContainer<StorageKeys> else { throw decryptionError() }
        let value: Any
        // Handle optionals as non-optionals -> they are handled beforehand with "prim": "None"
        switch type {
        case is Int.Type, is Int?.Type:
            value = try container.decodeRPC(Int.self, forKey: .int)
        case is String.Type, is String?.Type:
            value = try container.decode(String.self, forKey: .string)
        case is Bool.Type, is Bool?.Type:
            value = try container.decodeRPC(Bool.self, forKey: .prim)
        default:
            value = try container.decode(T.self, forKey: .prim)
        }
        guard let unwrappedValue = value as? T else { throw decryptionError() }
        return unwrappedValue
    }

    func decodeRPC<T: Decodable>(_ type: [T].Type, forKey key: K) throws -> T {
        var arrayContainer = try nestedUnkeyedContainer(forKey: key)
        let genericArray: [Any] = try arrayContainer.decodeRPC([Any].self)
        guard let finalArray = genericArray as? T else { throw decryptionError() }
        return finalArray
    }

    func decodeRPC(_ type: Int.Type, forKey key: K) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        guard let decodedInt = Int(intString) else { throw decryptionError() }
        return decodedInt
    }

    func decodeRPC(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let boolString = try decode(String.self, forKey: key)
        switch boolString {
        case "True": return true
        case "False": return false
        default: throw decryptionError()
        }
    }
}
