//
//  ContractOperation.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/7/18.
//

import Foundation

/** An operation to transact XTZ between address and contract with input. */
public class ContractOperation<T: Encodable>: TransactionOperation {
    private let input: T?
    private let operationName: String

    /**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The wallet that is sending the XTZ.
     - Parameter to: The contract's address that is receiving the XTZ.
     - Parameter input: Input to be sent to the contract.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     */
    public convenience init(amount: TezToken, source: Wallet, destination: String, input: T?, operationName: String, operationFees: OperationFees? = nil) {
        self.init(amount: amount, source: source.address, destination: destination, input: input, operationName: operationName, operationFees: operationFees)
    }

    /**
     - Parameter amount: The amount of XTZ to transact.
     - Parameter source: The source address to XTZ from.
     - Parameter to: The contract's address that is receiving the XTZ.
     - Parameter input: Input to be sent to the contract.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     */
    public init(amount: TezToken, source: String, destination: String, input: T?, operationName: String, operationFees: OperationFees? = nil) {
        self.input = input
        self.operationName = operationName
        super.init(amount: amount, source: source, destination: destination, operationFees: operationFees)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var parametersContainer = encoder.container(keyedBy: TransactionOperationKeys.self)
        let contractEntrypoint = ContractEntrypoint(entrypoint: operationName, value: input)
        try parametersContainer.encode(contractEntrypoint, forKey: .parameters)
    }
}

public struct ContractEntrypoint<T: Encodable>: Encodable {
    let entrypoint: String
    let value: T?
    
    enum CodingKeys: String, CodingKey {
        case entrypoint
        case value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entrypoint, forKey: .entrypoint)
        if let value = value {
            try container.encodeRPC(value, forKey: .value)
        } else if value is Never? {
            try container.encode(UnitValue(), forKey: .value)
        }
    }
}

private struct UnitValue: Encodable {
    let prim: String = "Unit"
}
