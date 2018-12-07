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

    public convenience init(amount: TezToken, source: Wallet, destination: String, input: T) {
        self.init(amount: amount, source: source.address, destination: destination, input: input)
    }

    /**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The contract's address that is receiving the XTZ.
     - Parameter input: Input to be sent to the contract.
     */
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
