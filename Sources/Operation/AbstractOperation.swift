import Foundation

/**
 * An abstract super class representing an operation to perform on the blockchain. Common parameters
 * across operations and default parameter values are provided by the abstract class's
 * implementation.
 */
public class AbstractOperation: Operation {
	/** A Tezos balance representing 0. */
	public static let zeroTezosBalance = TezosBalance(balance: "0")!

	/** A Tezos balance that is the default used for gas and storage limits. */
	public static let defaultLimitTezosBalance = TezosBalance(balance: "10000")!

	public let source: String
	public let kind: OperationKind
	public let fee: TezosBalance
	public let gasLimit: TezosBalance
	public let storageLimit: TezosBalance
	public var requiresReveal: Bool {
		switch self.kind {
		case .delegation, .transaction, .origination:
			return true
		case .activateAccount, .reveal:
			return false
		}
	}

	public var dictionaryRepresentation: [String: String] {
		var operation: [String: String] = [:]
		operation["kind"] = kind.rawValue
		operation["storage_limit"] = storageLimit.rpcRepresentation
		operation["gas_limit"] = gasLimit.rpcRepresentation
		operation["fee"] = fee.rpcRepresentation
		operation["source"] = source

		return operation
	}

	public init(source: String,
		kind: OperationKind,
		fee: TezosBalance = AbstractOperation.zeroTezosBalance,
		gasLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance,
		storageLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance) {
		self.source = source
		self.kind = kind
		self.fee = fee
		self.gasLimit = gasLimit
		self.storageLimit = storageLimit
	}
}

private enum OperationKeys: String, CodingKey {
    case kind = "kind"
    case storageLimit = "storage_limit"
    case gasLimit = "gas_limit"
    case fee = "fee"
    case source = "source"
}

extension AbstractOperation: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OperationKeys.self)
        try container.encode(kind.rawValue, forKey: .kind)
        try container.encode(storageLimit, forKey: .storageLimit)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(fee, forKey: .fee)
        try container.encode(source, forKey: .source)
    }

}
