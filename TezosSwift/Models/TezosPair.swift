//
//  TezosPair.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/8/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

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

extension TezosPair: RPCCodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StorageKeys.self)
        var mutableContainer = try container.nestedUnkeyedContainer(forKey: .args)
        // Hold container (can't decode it twice)
        let storageContainer: UnkeyedDecodingContainer?
        (first, storageContainer) = try mutableContainer.decodeElement()
        (second, _) = try mutableContainer.decodeElement(previousContainer: storageContainer)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StorageKeys.self)
        try container.encode(TezosPrimaryType.pair, forKey: .prim)
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

