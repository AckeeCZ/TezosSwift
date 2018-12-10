import Foundation

/** An operation to set a register and address as a delegate. */
public class RegisterDelegateOperation: Operation {
	/** The address that will be set as the delegate. */
	public let delegate: String

    // Taken from: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md
    /// Default fees for operation
    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001272), gasLimit: Tez(0.010000), storageLimit: Tez.zero) }
    
	/**
     - Parameter delegate: The address will register as a delegate.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     */
	public init(delegate: String, operationFees: OperationFees? = nil) {
		self.delegate = delegate
		super.init(source: delegate, kind: .delegation, operationFees: operationFees ?? RegisterDelegateOperation.defaultFees)
	}

    // MARK: Encodable
    private enum RegisterDelegateOperationKeys: String, CodingKey {
        case delegate = "delegate"
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: RegisterDelegateOperationKeys.self)
        try container.encode(delegate, forKey: .delegate)
    }
}
