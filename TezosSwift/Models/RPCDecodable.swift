//
//  RPCDecodable.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/26/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

public protocol RPCDecodable: Decodable {}
extension Int: RPCDecodable {}
extension UInt: RPCDecodable {}
extension Bool: RPCDecodable {}
extension String: RPCDecodable {}
extension Data: RPCDecodable {}
extension Tez: RPCDecodable {}
extension Mutez: RPCDecodable {}
extension Set: RPCDecodable where Element : RPCDecodable {}
extension Array: RPCDecodable where Element : RPCDecodable {}
extension Optional: RPCDecodable where Wrapped: RPCDecodable {}

extension UnkeyedDecodingContainer {
    func corruptedError() -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        return DecodingError.dataCorrupted(context)
    }

    public mutating func decodeRPC<T: RPCDecodable>(_ type: Set<T>.Type) throws -> Set<T> {
        var set: Set<T> = []
        while !isAtEnd {
            let container = try nestedContainer(keyedBy: StorageKeys.self)
            let element  = try container.decodeRPC(T.self)
            set.insert(element)
        }
        return set
    }

    public mutating func decodeRPC<T: RPCDecodable>(_ type: [T].Type) throws -> [T] {
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

    public func decodeRPC(_ type: Int.Type, forKey key: Key) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        guard let decodedInt = Int(intString) else { throw decryptionError() }
        return decodedInt
    }

    public func decodeRPC(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        let boolString = try decode(String.self, forKey: key)
        switch boolString {
        case "True": return true
        case "False": return false
        default: throw decryptionError()
        }
    }

    public func decodeRPC(_ type: Data.Type, forKey key: Key) throws -> Data {
        let dataString = try decode(String.self, forKey: key)
        guard let decodedData = dataString.data(using: .utf8) else { throw decryptionError() }
        return decodedData
    }

    public func decodeRPC<T: RPCDecodable>(_ type: Set<T>.Type, forKey key: Key) throws -> Set<T> {
        var arrayContainer = try nestedUnkeyedContainer(forKey: key)
        return try arrayContainer.decodeRPC(type)
    }

    public func decodeRPC<T: RPCDecodable>(_ type: [T].Type, forKey key: Key) throws -> [T] {
        var arrayContainer = try nestedUnkeyedContainer(forKey: key)
        return try arrayContainer.decodeRPC(type)
    }
}

extension KeyedDecodingContainerProtocol where Key == StorageKeys {

    public func decodeRPC<T>(_ type: T?.Type) throws -> T? where T : RPCDecodable {
        let tezosOptional = try decode(TezosPrimaryType.self, forKey: .prim)
        guard tezosOptional == .some else { return nil }
        var optionalContainer = try nestedUnkeyedContainer(forKey: .args)
        let nestedContainer = try optionalContainer.nestedContainer(keyedBy: StorageKeys.self)
        return try nestedContainer.decodeRPC(T.self)
    }

    public func decodeRPC(_ type: Int.Type) throws -> Int {
        return try decodeRPC(Int.self, forKey: .int)
    }

    public func decodeRPC(_ type: UInt.Type) throws -> UInt {
        return try UInt(decodeRPC(Int.self, forKey: .int))
    }

    public func decodeRPC(_ type: Bool.Type) throws -> Bool {
        return try decodeRPC(Bool.self, forKey: .prim)
    }

    public func decodeRPC(_ type: String.Type) throws -> String {
        return try decode(String.self, forKey: .string)
    }

    public func decodeRPC(_ type: Data.Type) throws -> Data {
        return try decodeRPC(Data.self, forKey: .bytes)
    }

    public func decodeRPC(_ type: Mutez.Type) throws -> Mutez {
        return try decode(Mutez.self, forKey: .int)
    }

    public func decodeRPC(_ type: Date.Type) throws -> Date {
        let timestampString = try decodeRPC(String.self)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = dateFormatter.date(from: timestampString) else { throw decryptionError() }
        return date
    }

    public func decodeRPC<T: RPCDecodable>(_ type: T.Type) throws -> T {
        // TODO: Would be nice to do this generically, thus supporting right away all RPCDecodable types
        let value: Any
        switch type {
        case is Int.Type, is Int?.Type:
            value = try decodeRPC(Int.self)
        case is UInt.Type, is UInt?.Type:
            value = try decodeRPC(UInt.self)
        case is String.Type, is String?.Type:
            value = try decodeRPC(String.self)
        case is Bool.Type, is Bool?.Type:
            value = try decodeRPC(Bool.self)
        case is Data.Type, is Data?.Type:
            value = try decodeRPC(Data.self)
        case is Mutez.Type, is Mutez?.Type:
            value = try decodeRPC(Mutez.self)
        case is Date.Type, is Date?.Type:
            value = try decodeRPC(Date.self)
        default:
            value = try decode(type, forKey: .prim)
        }
        guard let unwrappedValue = value as? T else { throw decryptionError() }
        return unwrappedValue
    }
}

extension UnkeyedDecodingContainer {
    mutating func decodeCollectionElement<T: RPCDecodable>(previousContainer: UnkeyedDecodingContainer? = nil) throws -> (T, UnkeyedDecodingContainer?) {
        let subjectDescription = Mirror(reflecting: T.self).description
        if subjectDescription.contains("String") {
            let collection: [String] = try decodeCollection()
            return try typecheckCollection(T.self, collection: collection, previousContainer: previousContainer)
        } else if subjectDescription.contains("Int") {
            let collection: [Int] = try decodeCollection()
            return try typecheckCollection(T.self, collection: collection, previousContainer: previousContainer)
        } else if subjectDescription.contains("UInt") {
            let collection: [UInt] = try decodeCollection()
            return try typecheckCollection(T.self, collection: collection, previousContainer: previousContainer)
        } else if subjectDescription.contains("Bool") {
            let collection: [Bool] = try decodeCollection()
            return try typecheckCollection(T.self, collection: collection, previousContainer: previousContainer)
        } else if subjectDescription.contains("Mutez") {
            let collection: [Mutez] = try decodeCollection()
            return try typecheckCollection(T.self, collection: collection, previousContainer: previousContainer)
        } else if subjectDescription.contains("Data") {
            let collection: [Data] = try decodeCollection()
            return try typecheckCollection(T.self, collection: collection, previousContainer: previousContainer)
        } else {
            throw TezosError.unsupportedTezosType
        }
    }

    func typecheckCollection<T: RPCDecodable, U: Collection>(_ type: T.Type, collection: U, previousContainer: UnkeyedDecodingContainer?) throws -> (T, UnkeyedDecodingContainer?) {
        guard let finalArray = collection as? T else { throw TezosError.unsupportedTezosType }

        return (finalArray, nil)
    }

    func typecheckCollection<T: RPCDecodable, U: Collection>(_ type: T.Type, collection: U, previousContainer: UnkeyedDecodingContainer?) throws -> (T, UnkeyedDecodingContainer?) where U.Element: Hashable {
        if let finalArray = collection as? T {
            return (finalArray, nil)
        }

        guard let set = Set<U.Element>(collection) as? T else { throw TezosError.unsupportedTezosType }

        return (set, nil)
    }

    private mutating func decodeCollection<T: RPCDecodable & Collection>() throws -> T where T.Element: RPCDecodable {
        var arrayContainer = try nestedUnkeyedContainer()
        var array: [T.Element] = []
        while !arrayContainer.isAtEnd {
            let container = try arrayContainer.nestedContainer(keyedBy: StorageKeys.self)
            let element = try container.decodeRPC(T.Element.self)
            array.append(element)
        }

        guard let finalArray = array as? T else { throw TezosError.unsupportedTezosType }
        return finalArray
    }

    private func isCollection<T>(_ type: T.Type) -> Bool {
        let collectionsTypes = ["Set", "Array"]
        let subjectType = Mirror(reflecting: type).description

        for type in collectionsTypes {
            if subjectType.contains(type) { return true }
        }

        return false
    }

    mutating func decodeElement<T: RPCDecodable>(previousContainer: UnkeyedDecodingContainer? = nil) throws -> (T, UnkeyedDecodingContainer?) {
        if isCollection(T.self) {
            return try decodeCollectionElement(previousContainer: previousContainer)
        }

        if var currentContainer = previousContainer {
            let container = try currentContainer.nestedContainer(keyedBy: StorageKeys.self)
            return (try container.decodeRPC(T.self), currentContainer)
        }
        let container = try nestedContainer(keyedBy: StorageKeys.self)
        let primaryType = try container.decodeIfPresent(TezosPrimaryType.self, forKey: .prim).self
        if primaryType == .pair || primaryType == .some || primaryType == .map {
            var mutableSomeContainer = try container.nestedUnkeyedContainer(forKey: .args)
            let someContainer = try mutableSomeContainer.nestedContainer(keyedBy: StorageKeys.self)
            return (try someContainer.decodeRPC(T.self), mutableSomeContainer)
        } else {
            return (try container.decodeRPC(T.self), nil)
        }
    }
}
