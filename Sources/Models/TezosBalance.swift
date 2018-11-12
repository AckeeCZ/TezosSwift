import Foundation

/**
 * A model class representing a balance of Tezos.
 */
public struct TezosBalance {
    /** The number of decimal places available in Tezos values. */
    private let decimalDigitCount = 6

    /**
     * A string representing the integer amount of the balance.
     * For instance, a balance of 123.456 would be represented in this field as "123".
     */
    private let integerAmount: String

    /**
     * A string representing the decimal amount of the balance.
     * For instance, a balance of 123.456 would be represented in this field as "456".
     */
    private let decimalAmount: String

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
    public init(balance: Double) {
        let integerValue = Int(balance)

        // Convert decimalDigitCount significant digits of decimals into integers to avoid having to
        // deal with decimals.
        let multiplierDoubleValue = (pow(10, decimalDigitCount) as NSDecimalNumber).doubleValue
        let multiplierIntValue = (pow(10, decimalDigitCount) as NSDecimalNumber).intValue
        let significantDecimalDigitsAsInteger = Int(balance * multiplierDoubleValue)
        let significantIntegerDigitsAsInteger = integerValue * multiplierIntValue
        let decimalValue = significantDecimalDigitsAsInteger - significantIntegerDigitsAsInteger

        self.integerAmount = String(integerValue)

        // Decimal values need to be at least decimalDigitCount long. If the decimal value resolved to
        // be less than 6 then the number dropped leading zeros. E.G. '0' instead of '000000' or '400'
        // rather than 000400.
        var paddedDecimalAmount = String(decimalValue)
        while paddedDecimalAmount.count < decimalDigitCount {
            paddedDecimalAmount = "0" + paddedDecimalAmount
        }
        self.decimalAmount = paddedDecimalAmount
    }

    /**
     * Initialize a new balance from an RPC representation of a balance.
     */
    public init?(balance: String) {
        // Make sure the given string only contains digits.
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: balance)) else {
            return nil
        }

        // Pad small numbers with up to six zeros so that the below slicing works correctly
        var paddedBalance = balance
        while paddedBalance.count < decimalDigitCount {
            paddedBalance = "0" + paddedBalance
        }

        let integerDigitEndIndex =
            paddedBalance.index(paddedBalance.startIndex,
                                offsetBy: paddedBalance.count - decimalDigitCount)

        let integerString = paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex].count > 0 ? paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex] : "0"
        let decimalString = paddedBalance[integerDigitEndIndex..<paddedBalance.endIndex]

        self.integerAmount = String(integerString)
        self.decimalAmount = String(decimalString)
    }
}

extension TezosBalance: Equatable {
    public static func == (lhs: TezosBalance, rhs: TezosBalance) -> Bool {
        return lhs.rpcRepresentation == rhs.rpcRepresentation
    }
}


extension KeyedDecodingContainer {
    func decode(_ type: TezosBalance.Type, forKey key: K) throws -> TezosBalance {
        let balanceString = try decode(String.self, forKey: key)
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        guard let balance = TezosBalance(balance: balanceString) else { throw DecodingError.dataCorrupted(context) }
        return balance
    }
}

extension KeyedEncodingContainer {
    mutating func encode(_ value: TezosBalance, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.rpcRepresentation, forKey: key)
    }
}
