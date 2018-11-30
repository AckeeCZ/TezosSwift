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
        try pairs.forEach {
            var mapContainer = mapArrayContainer.nestedContainer(keyedBy: StorageKeys.self)
            try mapContainer.encode(TezosPrimaryType.map, forKey: .prim)
            var argsContainer = mapContainer.nestedUnkeyedContainer(forKey: .args)
            try argsContainer.encodeRPC($0.first)
            try argsContainer.encodeRPC($0.second)
        }
    }
}
