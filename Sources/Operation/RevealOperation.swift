import Foundation

/**
 * An operation to reveal an address.
 *
 * Note that TezosKit will automatically inject this operation when required for supported
 * operations.
 */
public class RevealOperation: Operation {

	/** The public key for the address being revealed. */
	public let publicKey: String

	/**
   * Initialize a new reveal operation for the given wallet.
   *
   * @param wallet The wallet that will be revealed.
   */
	public convenience init(from wallet: Wallet) {
		self.init(from: wallet.address, publicKey: wallet.keys.publicKey)
	}

	/**
   * Initialize a new reveal operation.
   *
   * @param address The address to reveal.
   * @param publicKey The public key of the address to reveal.
   */
	public init(from address: String, publicKey: String) {
		self.publicKey = publicKey
		super.init(source: address,
			kind: .reveal,
			fee: Operation.zeroTezosBalance,
			gasLimit: Operation.zeroTezosBalance,
			storageLimit: Operation.zeroTezosBalance)
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
