import Foundation

public protocol TezToken {
    /**
     * A representation of the given balance for use in RPC requests.
     */
    var rpcRepresentation: String { get }
}

public struct Mutez: TezToken {

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

/**
 * A model class representing a balance of Tezos.
 */
public struct Tez: TezToken {

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

extension Mutez: Equatable {
    public static func == (lhs: Mutez, rhs: Mutez) -> Bool {
        return lhs.rpcRepresentation == rhs.rpcRepresentation
    }
}


extension KeyedDecodingContainerProtocol {
    fileprivate func getAmounts(from balanceString: String) throws -> (String, String) {
        // Make sure the given string only contains digits.
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: balanceString)) else { throw TezosError.decryptionFailed }

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

        return (String(integerString), String(decimalString))
    }
}

extension Mutez: Codable {}
extension Tez: Codable {}

extension KeyedDecodingContainerProtocol {
    func decode(_ type: Tez.Type, forKey key: Key) throws -> Tez {
        let amount = try decodeRPC(Int.self, forKey: key)
        return Tez(Double(amount))
    }
}

extension KeyedEncodingContainer {
    mutating func encode(_ value: TezToken, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.rpcRepresentation, forKey: key)
    }
}

extension KeyedDecodingContainerProtocol {
    func decode(_ type: Mutez.Type, forKey key: Key) throws -> Mutez {
        let amount = try decodeRPC(Int.self, forKey: key)
        return Mutez(Double(amount))
    }
}
