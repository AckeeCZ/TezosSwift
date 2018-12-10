import Foundation

/**
 * An abstract super class representing an operation to perform on the blockchain.

 Common parameters
 across operations and default parameter values are provided by the abstract class's
 implementation.
 */
public class Operation: Encodable {
	public let source: String
	public let kind: OperationKind

    // Taken from: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md
    /// Default fees for operation
    public class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001272), gasLimit: Tez(0.010100), storageLimit: Tez(0.000257)) }
    public internal(set) var operationFees: OperationFees?
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
        operationFees: OperationFees? = nil) {
		self.source = source
		self.kind = kind
		self.operationFees = operationFees
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
        let operationFees = self.operationFees ?? Operation.defaultFees
        try container.encode(operationFees.storageLimit, forKey: .storageLimit)
        try container.encode(operationFees.gasLimit, forKey: .gasLimit)
        try container.encode(operationFees.fee, forKey: .fee)
        try container.encode(source, forKey: .source)
    }
}
