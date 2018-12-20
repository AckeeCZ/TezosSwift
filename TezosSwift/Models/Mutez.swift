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

    /// Zero amount of Tez
    public static let zero: TezToken = Mutez(0)
    public let amount: Int
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

    public init(_ amount: Int) {
        let mutez = Tez(Double(amount) * 0.000001)
        self.integerAmount = mutez.integerAmount
        self.decimalAmount = mutez.decimalAmount
        self.amount = amount
    }
}

extension KeyedDecodingContainerProtocol {
    public func decode(_ type: Mutez.Type, forKey key: Key) throws -> Mutez {
        let amount = try decodeRPC(Int.self, forKey: key)
        return Mutez(amount)
    }

    public func decodeIfPresent(_ type: Mutez.Type, forKey key: Key) throws -> Mutez? {
        guard let amount = try? decodeRPC(Int.self, forKey: key) else { return nil }
        return Mutez(amount)
    }
}

extension Mutez: Equatable {
    public static func == (lhs: Mutez, rhs: Mutez) -> Bool {
        return lhs.rpcRepresentation == rhs.rpcRepresentation
    }
}

extension Mutez {
    static func +(lhs: Mutez, rhs: Mutez) -> Mutez {
        let mutez = lhs.amount + rhs.amount
        return Mutez(mutez)
    }
}
