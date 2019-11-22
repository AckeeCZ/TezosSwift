import Foundation

/**
 * An operation to reveal an address.

 Note that TezosKit will automatically inject this operation when required for supported
 operations.
 */
public class RevealOperation: Operation {

	/** The public key for the address being revealed. */
	public let publicKey: String

    // Taken from: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md
    /// Default fees for operation
    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001272), gasLimit: Tez(0.010000), storageLimit: Tez.zero) }

    /**
     Initialize a new reveal operation for the given wallet.

     - Parameter wallet: The wallet that will be revealed.
     */
	public convenience init(from wallet: Wallet, operationFees: OperationFees? = nil) {
        self.init(from: wallet.address, publicKey: wallet.keys.publicKey, operationFees: operationFees)
	}

	/**
     Initialize a new reveal operation.

     - Parameter address: The address to reveal.
     - Parameter publicKey: The public key of the address to reveal.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
   */
    public init(from address: String, publicKey: String, operationFees: OperationFees? = nil) {
		self.publicKey = publicKey
		super.init(source: address,
			kind: .reveal,
            operationFees: operationFees ?? RevealOperation.defaultFees)
	}

    // MARK: Encodable
    private enum RevealOperationKeys: String, CodingKey {
        case publicKey = "public_key"
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: RevealOperationKeys.self)
        try container.encode(publicKey, forKey: .publicKey)
    }
}
