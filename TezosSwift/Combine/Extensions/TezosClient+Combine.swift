//
//  TezosClient+Combine.swift
//  TezosSwift-Combine
//
//  Created by Marek Fořt on 11/22/19.
//  Copyright © 2019 Ackee. All rights reserved.
//

import Foundation
import Combine
import TezosSwift

public extension TezosClient {
     /// Retrieve data about the chain head.
    func chainHeadPublisher() -> ContractPublisher<ChainHead> {
        ContractPublisher(send: { self.chainHead(completion: $0) })
    }
    
    func managerAddressKeyPublisher(of address: String) -> ContractPublisher<ManagerKey> {
        ContractPublisher(send: { self.managerAddressKey(of: address, completion: $0) })
    }

     /// Retrieve the balance of a given address.
     func balancePublisher(of address: String) -> ContractPublisher<Mutez> {
        ContractPublisher(send: { self.balance(of: address, completion: $0) })
     }

     /// Retrieve the address counter for the given address.
     func statusPublisher(of address: String) -> ContractPublisher<ContractStatus> {
        ContractPublisher(send: { self.status(of: address, completion: $0) })
     }

     /// Retrieve the delegate of a given address.
     func delegatePublisher(of address: String) -> ContractPublisher<String> {
        ContractPublisher(send: { self.delegate(of: address, completion: $0) })
     }

     /// Retrieve the address counter for the given address.
     func counterPublisher(of address: String) -> ContractPublisher<Int> {
        ContractPublisher(send: { self.counter(of: address, completion: $0) })
     }

     /// Retrieve the expected quorum.
     func currentQuorumPublisher() -> ContractPublisher<Int> {
        ContractPublisher(send: { self.currentQuorum(completion: $0) })
     }

     /// Retrieve the expected quorum.
     func currentPeriodKindPublisher() -> ContractPublisher<PeriodKind> {
        ContractPublisher(send: { self.currentPeriodKind(completion: $0) })
     }

     /// Sum of ballots cast so far during a voting period.
     func ballotsSumPublisher() -> ContractPublisher<BallotsSum> {
        ContractPublisher(send: { self.ballotsSum(completion: $0) })
     }

     /// List of delegates with their voting weight, in number of rolls
     func delegatesListPublisher() -> ContractPublisher<[DelegateStatus]> {
        ContractPublisher(send: { self.delegatesList(completion: $0) })
     }

    /// Transact Tezos between accounts.
    /// - Parameters:
    ///     - amount: The amount of Tezos to send.
    ///     - recipientAddress: The address which will receive the balance.
    ///     - from: Wallet to send Tezos from.
    ///     - operationFees: to include in the transaction if the call is being made to a smart contract.
    ///     - completion: A completion block which will be called with a string representing the transaction ID hash if the operation was successful.
     func sendPublisher(amount: TezToken,
                        to recipientAddress: String,
                        from wallet: Wallet,
                        operationFees: OperationFees? = nil) -> ContractPublisher<String> {
        ContractPublisher(send: { self.send(amount: amount, to: recipientAddress, from: wallet, completion: $0) })
     }

    /// Transact Tezos between accounts with input.
    /// - Parameters:
    ///     - amount: The amount of Tezos to send.
    ///     - recipientAddress: The address which will receive the balance.
    ///     - wallet: Wallet to send Tezos from.
    ///     - operationFees: to include in the transaction if the call is being made to a smart contract.
    ///     - completion: A completion block which will be called with a string representing the transaction ID hash if the operation was successful.
    ///     - input: Input (parameter) to send to contract.
     func callPublisher<T: Encodable>(amount: TezToken,
                                      to recipientAddress: String,
                                      from wallet: Wallet,
                                      input: T,
                                      operationFees: OperationFees? = nil) -> ContractPublisher<String> {
        ContractPublisher(send: { self.call(amount: amount, to: recipientAddress, from: wallet, input: input, completion: $0) })
     }

    ///Originate a new account from the given account.
    /// - Parameters:
    ///     - initialBalance: Initial balance to create new account with
    ///     - managerAddress: The address which will manage the new account. Defaults to wallet.
    ///     - wallet: The wallet to use to sign the operation for the address.
    ///     - operationFees: OperationFees for the transaction. If nil, default fees are used.
     func originateAccountPublisher(initialBalance: TezToken,
                                    managerAddress: String? = nil,
                                    from wallet: Wallet,
                                    operationFees: OperationFees? = nil) -> ContractPublisher<String> {
        ContractPublisher(send: { self.originateAccount(initialBalance: initialBalance, managerAddress: managerAddress, from: wallet, operationFees: operationFees, completion: $0) })
     }

    /// Delegate the balance of an originated account.
    /// - Note: that only KT1 accounts can delegate. TZ1 accounts are not able to delegate. This invariant is not checked on an input to this methods. Thus, the source address must be a KT1 address and he keys to sign the operation for the address are the keys used to manage the TZ1 address.
    /// - Parameters:
    ///     - source: The address sending the tezos.
    ///     - delegate: Delegate's address.
    ///     - keys: The keys to use to sign the operation for the address.
    ///     - operationFees: to include in the transaction if the call is being made to a smart contract.
     func delegatePublisher(from source: String,
                            to delegate: String,
                            keys: Keys,
                            operationFees: OperationFees? = nil) -> ContractPublisher<String> {
        ContractPublisher(send: { self.delegate(from: source, to: delegate, keys: keys, operationFees: operationFees, completion: $0) })
     }

     /// Register an address as a delegate.
    /// - Parameters:
    ///     - recipientAddress: The address which will receive the balance.
    ///     - keys: The keys to use to sign the operation for the address.
    ///     - operationFees: to include in the transaction if the call is being made to a smart contract.
    func registerDelegatePublisher(delegate: String,
                                   keys: Keys,
                                   operationFees: OperationFees? = nil) -> ContractPublisher<String> {
        ContractPublisher(send: { self.registerDelegate(delegate: delegate, keys: keys, operationFees: operationFees, completion: $0) })
     }

    /// Clear the delegate of an originated account.
    /// - Parameters:
    ///     - wallet: The wallet which is removing the delegate.
    ///     - operationFees: to include in the transaction if the call is being made to a smart contract.
     func undelegatePublisher(wallet: Wallet,
                              operationFees: OperationFees? = nil) -> ContractPublisher<String> {
        ContractPublisher(send: { self.undelegate(wallet: wallet, operationFees: operationFees, completion: $0) })
     }

    /// Forge, sign, preapply and then inject a single operation.
    /// - Parameters:
    ///     - operation: The operation which will be used to forge the operation.
    ///     - source: The address performing the operation.
    ///     - keys: The keys to use to sign the operation for the address.
    func forgeSignPreapplyAndInjectOperationPublisher(operation: TezosSwift.Operation,
                                                      source: String,
                                                      keys: Keys) -> ContractPublisher<String> {
        ContractPublisher(send: { self.forgeSignPreapplyAndInjectOperation(operation: operation, source: source, keys: keys, completion: $0) })
     }
}
