//
//  TezosMap.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/29/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

public struct TezosMap<T: RPCCodable, U: RPCCodable> {
    public let pairs: [TezosPair<T, U>]

    public init(pairs: [TezosPair<T, U>]) {
        self.pairs = pairs
    }
}

extension TezosMap: Codable {
    public init(from decoder: Decoder) throws {
        self.pairs = try decoder.singleValueContainer().decode([TezosPair<T, U>].self)
    }

    public func encode(to encoder: Encoder) throws {
        var mapArrayContainer = encoder.unkeyedContainer()
        try encode(in: &mapArrayContainer)
    }
    
    fileprivate func encode(in container: inout UnkeyedEncodingContainer) throws {
        try pairs.forEach {
            var container = container.nestedContainer(keyedBy: StorageKeys.self)
            try container.encode(TezosPrimaryType.map, forKey: .prim)
            var argsContainer = container.nestedUnkeyedContainer(forKey: .args)
            try argsContainer.encodeRPC($0.first)
            try argsContainer.encodeRPC($0.second)
        }
    }
}

extension TezosMap: RPCCodable {
    public func encodeRPC<K>(in container: inout KeyedEncodingContainer<K>, forKey key: K) throws where K : CodingKey {
        var mapArrayContainer = container.nestedUnkeyedContainer(forKey: key)
        try encode(in: &mapArrayContainer)
    }
    
    public func encodeRPC<T>(in container: inout T) throws where T : UnkeyedEncodingContainer {
        var mapArrayContainer = container.nestedUnkeyedContainer()
        try encode(in: &mapArrayContainer)
        
    }
}
