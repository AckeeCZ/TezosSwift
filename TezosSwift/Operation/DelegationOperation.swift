import Foundation

/** An operation to set a delegate for an address. */
public class DelegationOperation: Operation {
	/** The address that will be set as the delegate. */
	public let delegate: String
    
	/**
     - Parameter source: The address that will delegate funds.
     - Parameter delegate: The address to delegate to.
   */
	public init(source: String, to delegate: String) {
		self.delegate = delegate
		super.init(source: source, kind: .delegation)
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
