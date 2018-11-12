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

    mutating func decodeElement<T: Decodable>(previousContainer: KeyedDecodingContainer<StorageKeys>? = nil) throws -> (T, KeyedDecodingContainer<StorageKeys>?) {
        if var arrayContainer = try? nestedUnkeyedContainer() {
            // Can I generically access generic's element type?
            let genericArray: [Any] = try arrayContainer.decodeRPC([Any].self)
            guard let finalArray = genericArray as? T else { throw TezosError.unsupportedTezosType }
            return (finalArray, nil)
        } else {
            if let currentContainer = previousContainer {
                return (try currentContainer.decodeRPC(T.self), currentContainer)
            }
            let container = try nestedContainer(keyedBy: StorageKeys.self)
            let primaryType = try container.decode(String.self, forKey: .prim).self
            if primaryType == "Pair" || primaryType == "Some" {
                // TODO: Check different ways of outputs for some (optional lists?)
                var mutableSomeContainer = try container.nestedUnkeyedContainer(forKey: .args)
                let someContainer = try mutableSomeContainer.nestedContainer(keyedBy: StorageKeys.self)
                return (try someContainer.decodeRPC(T.self), someContainer)
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
        let storageContainer: KeyedDecodingContainer<StorageKeys>?
        (first, storageContainer) = try mutableContainer.decodeElement()
        (second, _) = try mutableContainer.decodeElement(previousContainer: storageContainer)
    }
}

extension KeyedDecodingContainer {
    func corruptedError() -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        return DecodingError.dataCorrupted(context)
    }

    func decodeRPC<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard let container = self as? KeyedDecodingContainer<StorageKeys> else { throw corruptedError() }
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
        guard let unwrappedValue = value as? T else { throw corruptedError() }
        return unwrappedValue
    }

    func decodeRPC<T: Decodable>(_ type: [T].Type, forKey key: K) throws -> T {
        var arrayContainer = try nestedUnkeyedContainer(forKey: key)
        let genericArray: [Any] = try arrayContainer.decodeRPC([Any].self)
        guard let finalArray = genericArray as? T else { throw corruptedError() }
        return finalArray
    }

    func decodeRPC(_ type: Int.Type, forKey key: K) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        guard let decodedInt = Int(intString) else { throw corruptedError() }
        return decodedInt
    }

    func decodeRPC(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let boolString = try decode(String.self, forKey: key)
        switch boolString {
        case "True": return true
        case "False": return false
        default: throw corruptedError()
        }
    }
}
