//
//  TezosMap.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/29/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

struct TezosMap<T: RPCCodable, U: RPCCodable> {
    let pairs: [TezosPair<T, U>]
}

extension TezosMap: Codable {

    init(from decoder: Decoder) throws {
        self.pairs = try decoder.singleValueContainer().decode([TezosPair<T, U>].self)
    }

    func encode(to encoder: Encoder) throws {
        var mapArrayContainer = encoder.unkeyedContainer()
        try pairs.forEach {
            var mapContainer = mapArrayContainer.nestedContainer(keyedBy: StorageKeys.self)
            try mapContainer.encode("Elt", forKey: .prim)
            var argsContainer = mapContainer.nestedUnkeyedContainer(forKey: .args)
            try argsContainer.encodeRPC($0.first)
            try argsContainer.encodeRPC($0.second)
        }

    }
}
