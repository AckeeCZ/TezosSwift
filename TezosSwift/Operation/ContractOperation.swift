//
//  ContractOperation.swift
//  BigInt
//
//  Created by Marek Fořt on 12/7/18.
//

import Foundation

/** An operation to transact XTZ between address and contract with input. */
public class ContractOperation<T: Encodable>: TransactionOperation {
    private let input: T

    /**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The contract's address that is receiving the XTZ.
     - Parameter input: Input to be sent to the contract.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     */
    public convenience init(amount: TezToken, source: Wallet, destination: String, input: T, operationFees: OperationFees? = nil) {
        self.init(amount: amount, source: source.address, destination: destination, input: input, operationFees: operationFees)
    }

    /**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The source address to XTZ from.
     - Parameter to: The contract's address that is receiving the XTZ.
     - Parameter input: Input to be sent to the contract.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     */
    public init(amount: TezToken, source: String, destination: String, input: T, operationFees: OperationFees? = nil) {
        self.input = input

        super.init(amount: amount, source: source, destination: destination, operationFees: operationFees)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var parametersContainer = encoder.container(keyedBy: TransactionOperationKeys.self)
        try parametersContainer.encodeRPC(input, forKey: .parameters)
    }
}
