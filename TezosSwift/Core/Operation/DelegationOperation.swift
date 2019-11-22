import Foundation

/** An operation to set a delegate for an address. */
public class DelegationOperation: Operation {
	/** The address that will be set as the delegate. */
	public let delegate: String

    // Taken from: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md
    /// Default fees for operation
    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001272), gasLimit: Tez(0.010000), storageLimit: Tez.zero) }
    
	/**
     - Parameter source: The address that will delegate funds.
     - Parameter delegate: The address to delegate to.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
   */
	public init(source: String, to delegate: String, operationFees: OperationFees? = nil) {
		self.delegate = delegate
		super.init(source: source, kind: .delegation, operationFees: operationFees ?? DelegationOperation.defaultFees)
	}

    // MARK: Encodable
    private enum DelegationOperationKeys: String, CodingKey {
        case delegate = "delegate"
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: DelegationOperationKeys.self)
        try container.encode(delegate, forKey: .delegate)
    }
}
