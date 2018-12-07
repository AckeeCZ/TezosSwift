import Foundation

/** An operation to set a register and address as a delegate. */
public class RegisterDelegateOperation: Operation {
	/** The address that will be set as the delegate. */
	public let delegate: String
    
	/**
     - Parameter delegate: The address will register as a delegate.
     */
	public init(delegate: String) {
		self.delegate = delegate
		super.init(source: delegate, kind: .delegation)
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
