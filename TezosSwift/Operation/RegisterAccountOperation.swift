//
//  RegisterAccountOperation.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/14/18.
//

import Foundation

/** An operation that originates a new KT1 account. */
public class OriginateAccountOperation: Operation {
    // TODO: Support contract code

    // Min is 257, adding 20 for safety
    public override class var defaultFees: OperationFees { return OperationFees(fee: Mutez(1272), gasLimit: Mutez(10100), storageLimit: Mutez(277)) }
    let initialBalance: TezToken
    let managerAddress: String?

    /**
     - Parameter amount: The initial amount of XTZ to originate new account with.
     - Parameter managerAddress: The wallet that will be managing the new account. Defaults to source.
     - Parameter source: The wallet that is originating the account.
     - Parameter operationFees: Operation fees for this operation.
     */
    public convenience init(initialBalance: TezToken, managerAddress: String? = nil, source: Wallet, operationFees: OperationFees? = nil) {
        self.init(initialBalance: initialBalance, managerAddress: managerAddress, source: source.address, operationFees: operationFees)
    }

    /**
     - Parameter amount: The initial amount of XTZ to originate new account with.
     - Parameter managerAddress: The wallet that will be managing the new account. Defaults to source.
     - Parameter source: The address that is originating the account.
     - Parameter operationFees: Operation fees for this operation.
     */
    public init(initialBalance: TezToken, managerAddress: String? = nil, source: String, operationFees: OperationFees? = nil) {
        self.initialBalance = initialBalance
        self.managerAddress = managerAddress

        super.init(source: source, kind: .origination, operationFees: operationFees)
    }

    private enum CodingKeys: String, CodingKey {
        case managerPubkey = "managerPubkey"
        case balance = "balance"
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        let managerPubKey = managerAddress ?? source
        try container.encode(managerPubKey, forKey: .managerPubkey)
        try container.encode(initialBalance, forKey: .balance)
    }
}
