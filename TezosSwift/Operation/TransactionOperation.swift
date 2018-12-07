import Foundation

/** An operation to transact XTZ between addresses. */
public class TransactionOperation: Operation {
	private let amount: TezToken
	private let destination: String

	/**
   * @param amount The amount of XTZ to transact.
   * @param source The wallet that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   */
    public convenience init(amount: TezToken, source: Wallet, destination: String) {
        self.init(amount: amount, source: source.address, destination: destination)
	}

	/**
   * @param amount The amount of XTZ to transact.
   * @param from The address that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   */
    public init(amount: TezToken, source: String, destination: String) {
		self.amount = amount
		self.destination = destination

		super.init(source: source, kind: .transaction)
	}

    // MARK: Encodable
    fileprivate enum TransactionOperationKeys: String, CodingKey {
        case amount = "amounttt"
        case destination = "destination"
        case parameters = "parameters"
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TransactionOperationKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(destination, forKey: .destination)
    }
}

public class ContractOperation<T: Encodable>: TransactionOperation {
    private let input: T

    public convenience init(amount: TezToken, source: Wallet, destination: String, input: T) {
        self.init(amount: amount, source: source.address, destination: destination, input: input)
    }

    public init(amount: TezToken, source: String, destination: String, input: T) {
        self.input = input

        super.init(amount: amount, source: source, destination: destination)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var parametersContainer = encoder.container(keyedBy: TransactionOperationKeys.self)
        try parametersContainer.encodeRPC(input, forKey: .parameters)
    }
}
