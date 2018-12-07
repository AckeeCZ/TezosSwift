//
//  TezToken.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/30/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/// TezToken is a protocol to support arbitrary denotation of Tezos tokens
public protocol TezToken {
    /**
     * A representation of the given balance for use in RPC requests.
     */
    var rpcRepresentation: String { get }
}

extension KeyedEncodingContainer {
    mutating func encode(_ value: TezToken, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.rpcRepresentation, forKey: key)
    }
}
