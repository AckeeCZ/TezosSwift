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
    mutating func decodeElement<T: Decodable>() throws -> T {
        if var arrayContainer = try? nestedUnkeyedContainer() {
            // TODO: Generically access generic's element?
            var genericArray: [Any] = []

            while !arrayContainer.isAtEnd {
                let container = try arrayContainer.nestedContainer(keyedBy: StorageKeys.self)
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

            guard let finalArray = genericArray as? T else { throw TezosError.unsupportedTezosType }
            print(finalArray)
            return finalArray
        } else {
            let container = try nestedContainer(keyedBy: StorageKeys.self)
            let primaryType = try container.decode(String.self, forKey: .prim).self
            if primaryType == "Pair" {
                return try container.decode(T.self, forKey: .prim)
            } else if primaryType == "Some" {
                // TODO: Check different ways of outputs for some (optional lists?)
                var mutableSomeContainer = try container.nestedUnkeyedContainer(forKey: .args)
                let someContainer = try mutableSomeContainer.nestedContainer(keyedBy: StorageKeys.self)
                print(primaryType)
                return try someContainer.decodeRPC(T.self)
            } else {
                return try container.decodeRPC(T.self)
            }
        }
    }
}

extension TezosPair: Decodable {



    init(from decoder: Decoder) throws {
        var mutableContainer = try decoder.unkeyedContainer()
        //var arrayContainer = try mutableContainer.nestedUnkeyedContainer()
        self.first = try mutableContainer.decodeElement()
        //let container = try mutableContainer.nestedContainer(keyedBy: StorageKeys.self)

        self.second = try mutableContainer.decodeElement()


        //var container = try mutableContainer.nestedContainer(keyedBy: StorageKeys.self).nestedUnkeyedContainer(forKey: .args)


//        while !mutableContainer.isAtEnd {
//            var arrayContainer = try mutableContainer.nestedUnkeyedContainer()
//            if let arrayType = First.Type as? Collection.Type {
//
//            }
//            let array: Array<Any> = []
//            while !arrayContainer.isAtEnd {
//
//            }
//        }
//        while !container.isAtEnd {
//
//        }

        //decoder.container(keyedBy: StorageKeys.self).nestedUnkeyedContainer(forKey: .args)
//        let firstContainer = try container.nestedContainer(keyedBy: StorageKeys.self)
//        let secondContainer = try container.nestedContainer(keyedBy: StorageKeys.self)
//
//        let firstPrimaryType = try firstContainer.decode(String.self, forKey: .prim).self
//        if firstPrimaryType == "Pair" {
//            self.first = try firstContainer.decode(First.self, forKey: .args)
//        } else {
//            self.first = try firstContainer.decodeRPC(First.self, forKey: .prim).self
//        }
//
//        let secondPrimaryType = try secondContainer.decode(String.self, forKey: .prim).self
//        if secondPrimaryType == "Pair" {
//            self.second = try secondContainer.decode(Second.self, forKey: .args)
//        } else {
//            self.second = try secondContainer.decodeRPC(Second.self, forKey: .prim).self
//        }
    }
}



extension KeyedDecodingContainer {
    func decodeRPC<T>(_ type: T.Type) throws -> T where T : Decodable {

        guard let container = self as? KeyedDecodingContainer<StorageKeys> else {
            throw TezosError.unsupportedTezosType
        }
        print(type)
        print(type is Bool.Type)
        let value: Any
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
