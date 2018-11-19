import Foundation

/**
 * A model class representing a balance of Tezos.
 */
public struct Tez {
    /** The number of decimal places available in Tezos values. */
    fileprivate static let decimalDigitCount = 6

    /**
     * A string representing the integer amount of the balance.
     * For instance, a balance of 123.456 would be represented in this field as "123".
     */
    fileprivate let integerAmount: String

    /**
     * A string representing the decimal amount of the balance.
     * For instance, a balance of 123.456 would be represented in this field as "456".
     */
    fileprivate let decimalAmount: String

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
     * @warning Balances are accurate up to |decimalDigitCount| decimal places. Additional precision
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

extension Tez: Equatable {
    public static func == (lhs: Tez, rhs: Tez) -> Bool {
        return lhs.rpcRepresentation == rhs.rpcRepresentation
    }
}


extension KeyedDecodingContainer {
    func decode(_ type: Tez.Type, forKey key: K) throws -> Tez {
        let balanceString = try decode(String.self, forKey: key)
        // Make sure the given string only contains digits.
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: balanceString)) else { throw decryptionError() }

        // Pad small numbers with up to six zeros so that the below slicing works correctly
        var paddedBalance = balanceString
        while paddedBalance.count < Tez.decimalDigitCount {
            paddedBalance = "0" + paddedBalance
        }

        let integerDigitEndIndex =
            paddedBalance.index(paddedBalance.startIndex,
                                offsetBy: paddedBalance.count - Tez.decimalDigitCount)

        let integerString = paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex].count > 0 ? paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex] : "0"
        let decimalString = paddedBalance[integerDigitEndIndex..<paddedBalance.endIndex]

        return Tez(integerAmount: String(integerString), decimalAmount: String(decimalString))
    }
}

extension KeyedEncodingContainer {
    mutating func encode(_ value: Tez, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.rpcRepresentation, forKey: key)
    }
}
