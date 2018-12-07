//
//  TezosOr.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/26/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/** This type represents or Michelson type
 - Warning: This type is meant to be used by generated code from TezosGen
*/
public struct TezosOr<T: RPCCodable, U: RPCCodable> {
    public typealias Left = T
    public typealias Right = U
    public let left: Left?
    public let right: Right?

    public init?(left: Left?, right: Right?) {
        if let left = left {
            self.left = left
            self.right = nil
            return
        }

        if let right = right {
            self.left = nil
            self.right = right
            return
        }

        return nil
    }
}

extension TezosOr: RPCCodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StorageKeys.self)
        let primaryType = try container.decode(TezosPrimaryType.self, forKey: .prim).self
        var mutableSomeContainer = try container.nestedUnkeyedContainer(forKey: .args)
        let someContainer = try mutableSomeContainer.nestedContainer(keyedBy: StorageKeys.self)
        if primaryType == TezosPrimaryType.left {
            self.left = try someContainer.decodeRPC(Left.self)
            self.right = nil
        } else {
            self.left = nil
            self.right = try someContainer.decodeRPC(Right.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StorageKeys.self)

        if let left = self.left {
            try container.encode(TezosPrimaryType.left, forKey: .prim)
            var argsContainer = container.nestedUnkeyedContainer(forKey: .args)
            try argsContainer.encodeRPC(left)
        }

        if let right = self.right {
            try container.encode(TezosPrimaryType.right, forKey: .prim)
            var argsContainer = container.nestedUnkeyedContainer(forKey: .args)
            try argsContainer.encodeRPC(right)
        }
    }

    public func encodeRPC<K: CodingKey>(in container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try container.encode(self, forKey: key)
    }

    public func encodeRPC<T: UnkeyedEncodingContainer>(in container: inout T) throws {
        try container.encode(self)
    }
}
