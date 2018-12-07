//
//  Tez.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/30/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/**
 * A model class representing a balance of Tezos.
 */
public struct Tez: TezToken, Codable {

    /** The number of decimal places available in Tezos values. */
    fileprivate static let decimalDigitCount = 6

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

    /**
     * Initialize a new balance from a given decimal number.
     *
     * - Warning: Balances are accurate up to |decimalDigitCount| decimal places. Additional precision
     * is dropped.
     */
    public init(_ amount: Double) {
        let integerValue = Int(amount)

        // Convert decimalDigitCount significant digits of decimals into integers to avoid having to
        // deal with decimals.
        let multiplierDoubleValue = (pow(10, Tez.decimalDigitCount) as NSDecimalNumber).doubleValue
        let multiplierIntValue = (pow(10, Tez.decimalDigitCount) as NSDecimalNumber).intValue
        let significantDecimalDigitsAsInteger = Int(amount * multiplierDoubleValue)
        let significantIntegerDigitsAsInteger = integerValue * multiplierIntValue
        let decimalValue = significantDecimalDigitsAsInteger - significantIntegerDigitsAsInteger

        self.integerAmount = String(integerValue)

        // Decimal values need to be at least decimalDigitCount long. If the decimal value resolved to
        // be less than 6 then the number dropped leading zeros. E.G. '0' instead of '000000' or '400'
        // rather than 000400.
        var paddedDecimalAmount = String(decimalValue)
        while paddedDecimalAmount.count < Tez.decimalDigitCount {
            paddedDecimalAmount = "0" + paddedDecimalAmount
        }
        self.decimalAmount = paddedDecimalAmount
    }

    fileprivate init(integerAmount: String, decimalAmount: String) {
        self.integerAmount = integerAmount
        self.decimalAmount = decimalAmount
    }
}

extension KeyedDecodingContainerProtocol {
    public func decode(_ type: Tez.Type, forKey key: Key) throws -> Tez {
        let amount = try decodeRPC(Int.self, forKey: key)
        return Tez(Double(amount) * 0.000001)
    }
}

extension Tez: Equatable {
    public static func == (lhs: Tez, rhs: Tez) -> Bool {
        return lhs.rpcRepresentation == rhs.rpcRepresentation
    }
}
