//
//  Mutez.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/30/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/**
 * A model representing Tezos in Mutez (micro-tez).
 */
public struct Mutez: TezToken, Codable {

    let integerAmount: String
    let decimalAmount: String

    /**
     * A human readable representation of the given balance.
     */
    public var humanReadableRepresentation: String {
        return integerAmount + "." + decimalAmount
    }

    /**
     * A representation of the given balance for use in RPC requests.
     */
    public var rpcRepresentation: String {
        return integerAmount + decimalAmount
    }

    public init(_ amount: Double) {
        let mutez = Tez(amount * 0.000001)
        self.integerAmount = mutez.integerAmount
        self.decimalAmount = mutez.decimalAmount
    }

    fileprivate init(integerAmount: String, decimalAmount: String) {
        self.integerAmount = integerAmount
        self.decimalAmount = decimalAmount
    }
}

extension KeyedDecodingContainerProtocol {
    public func decode(_ type: Mutez.Type, forKey key: Key) throws -> Mutez {
        let amount = try decodeRPC(Int.self, forKey: key)
        return Mutez(Double(amount))
    }
}

extension Mutez: Equatable {
    public static func == (lhs: Mutez, rhs: Mutez) -> Bool {
        return lhs.rpcRepresentation == rhs.rpcRepresentation
    }
}
