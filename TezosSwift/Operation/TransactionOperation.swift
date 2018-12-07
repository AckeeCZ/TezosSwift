import Foundation

/** An operation to transact XTZ between addresses. */
public class TransactionOperation: Operation {
	private let amount: TezToken
	private let destination: String

	/**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The address that is receiving the XTZ.
   */
    public convenience init(amount: TezToken, source: Wallet, destination: String) {
        self.init(amount: amount, source: source.address, destination: destination)
	}

	/**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The address that is receiving the XTZ.
   */
    public init(amount: TezToken, source: String, destination: String) {
		self.amount = amount
		self.destination = destination

		super.init(source: source, kind: .transaction)
	}

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TransactionOperationKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(destination, forKey: .destination)
    }
}

// MARK: Encodable
enum TransactionOperationKeys: String, CodingKey {
    case amount = "amount"
    case destination = "destination"
    case parameters = "parameters"
}
