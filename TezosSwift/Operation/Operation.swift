import Foundation

/**
 * An abstract super class representing an operation to perform on the blockchain. Common parameters
 * across operations and default parameter values are provided by the abstract class's
 * implementation.
 */

public class Operation: Encodable {
	/** A Tezos balance representing 0. */
	public static let zeroTez = Tez(0)

	/** A Tezos balance that is the default used for gas and storage limits. */
	public static let defaultLimitTez = Tez(0.01)

	public let source: String
	public let kind: OperationKind
	public let fee: Tez
	public let gasLimit: Tez
	public let storageLimit: Tez
	public var requiresReveal: Bool {
		switch self.kind {
		case .delegation, .transaction, .origination:
			return true
		case .activateAccount, .reveal:
			return false
		}
	}
    public var counter: Int = 0

	public init(source: String,
		kind: OperationKind,
		fee: Tez = Operation.defaultLimitTez,
		gasLimit: Tez = Operation.defaultLimitTez,
		storageLimit: Tez = Operation.defaultLimitTez) {
		self.source = source
		self.kind = kind
		self.fee = fee
		self.gasLimit = gasLimit
		self.storageLimit = storageLimit
	}

    private enum OperationKeys: String, CodingKey {
        case kind = "kind"
        case counter = "counter"
        case storageLimit = "storage_limit"
        case gasLimit = "gas_limit"
        case fee = "fee"
        case source = "source"
        case parameters = "parameters"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OperationKeys.self)
        try container.encode(kind.rawValue, forKey: .kind)
        try container.encode(String(counter), forKey: .counter)
        try container.encode(storageLimit, forKey: .storageLimit)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(fee, forKey: .fee)
        try container.encode(source, forKey: .source)
    }
}
