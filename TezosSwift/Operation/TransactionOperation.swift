import Foundation

/** An operation to transact XTZ between addresses. */
public class TransactionOperation: Operation {
	let amount: TezToken
    let destination: String

    // Taken from: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md
    // Storage limit is zero if account active
    /// Default fees for operation
//    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001272), gasLimit: Tez(0.010100), storageLimit: Tez(0.000257)) }
    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001550), gasLimit: Tez(0.012749), storageLimit: Tez(0.000257)) }
    // TODO: Calculate fees!!! (opbytes: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md)
    /// Default fees for operation
//    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.03), gasLimit: Tez(0.03), storageLimit: Tez(0)) }

	/**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The address that is receiving the XTZ.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
   */
    public convenience init(amount: TezToken, source: Wallet, destination: String, operationFees: OperationFees? = nil) {
        self.init(amount: amount, source: source.address, destination: destination, operationFees: operationFees)
	}

	/**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The address that is receiving the XTZ.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
   */
    public init(amount: TezToken, source: String, destination: String, operationFees: OperationFees? = nil) {
		self.amount = amount
		self.destination = destination

		super.init(source: source, kind: .transaction, operationFees: operationFees)
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
