//
//  UndelegateOperation.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/14/18.
//

import Foundation

/** An operation to set a clear a delegate for an address. */
public class UndelegateOperation: Operation {
    // Taken from: https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md
    /// Default fees for operation
    public override class var defaultFees: OperationFees { return OperationFees(fee: Tez(0.001257), gasLimit: Tez(0.010000), storageLimit: Tez.zero) }

    /**
     - Parameter source: The address that will delegate funds.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     */
    public init(source: String, operationFees: OperationFees? = nil) {
        super.init(source: source, kind: .delegation, operationFees: operationFees ?? RegisterDelegateOperation.defaultFees)
    }
}
