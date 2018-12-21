import Foundation
import Result
import os

public typealias RPCCompletion<T: Decodable> = (Result<T, TezosError>) -> Void

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

/**
 * TezosClient is the gateway into the Tezos Network.
 *
 * Configuration
 * -------------
 * The client is initialized with a node URL which points to a node who can receive JSON RPC
 * requests from this client. The default not is rpc.tezrpc.me, a public node provided by TezTech.
 *
 * RPCs
 * -------------
 * TezosClient contains support for GET and POST RPCS and will make requests based on the
 * RPCs provided to it.
 *
 * All supported RPC operations are provided in the Sources/Requests folder of the project. In
 * addition, TezosClient provides convenience methods for constructing and sending all supported
 * operations.
 *
 * Clients who extend TezosKit functionality can send arbitrary RPCs by creating an RPC object that
 * conforms the the |TezosRPC| protocol and calling:
 *      func send<T>(rpc: TezosRPC<T>)
 *
 * Operations
 * -------------
 * TezosClient also contains support for performing signed operations on the Tezos blockchain. These
 * operations require a multi-step process to perform (forge, sign, pre-apply, inject).
 *
 * All supported signed operations are provided in the Sources/Operations folder of the project. In
 * addition, TezosClient provides convenience methods for constructing and performing all supported
 * signed operations.
 *
 * Clients who extend TezosKit functionality can send arbitrary signed operations by creating an
 * Operation object that conforms to the |Operation| protocol and calling:
 *      func forgeSignPreapplyAndInjectOperation(operation: Operation,
 *                                               source: String,
 *                                               keys: Keys,
 *                                               completion: @escaping RPCCompletion<String>)
 *
 * Clients can also send multiple signed operations at once by constructing an array of operations.
 * Operations are applied in the order they are given in the array. Clients should pass the array
 * to:
 *      func forgeSignPreapplyAndInjectOperations(operations: [Operation],
 *                                                source: String,
 *                                                keys: Keys,
 *                                                completion: @escaping RPCCompletion<String>)
 *
 * Some signed operations require an address be revealed in order to complete the operation. For
 * operations supported in TezosKit, the reveal operation will be automatically applied when needed.
 * For clients who create their own custom signed operations, TezosKit will apply the reveal
 * operation correctly as long as the |requiresReveal| bit on the custom Operation object is set
 * correctly.
 */
public class TezosClient {

	/** The URL session that will be used to manage URL requests. */
	private let urlSession: NetworkSession

	/** A URL pointing to a remote node that will handle requests made by this client. */
	private let remoteNodeURL: URL

    /// Handler of RPC responses
    private let rpcResponseHandler: RPCResponseHandler = RPCResponseHandler()

    private let subsystem = "ackee.TezosSwift.TezosClient"

    /**
     Initialize a new TezosClient.

     - Parameter remoteNodeURL: The path to the remote node.
     */
    public init(remoteNodeURL: URL) {
        self.remoteNodeURL = remoteNodeURL
        self.urlSession = URLSession.shared
    }

    /// Init used for unit for unit testing
    public init(remoteNodeURL: URL, urlSession: NetworkSession = URLSession.shared) {
        self.remoteNodeURL = remoteNodeURL
        self.urlSession = urlSession
    }

    /** Retrieve data about the chain head. */
    public func chainHead(completion: @escaping RPCCompletion<ChainHead>) {
        let endpoint = "/chains/main/blocks/head"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /** Retrieve manager key. */
    public func managerAddressKey(of address: String, completion: @escaping RPCCompletion<ManagerKey>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/manager_key"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /** Retrieve the balance of a given address. */
    public func balance(of address: String, completion: @escaping RPCCompletion<Mutez>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
        let rpcCompletion: RPCCompletion<Int> = { result in
            switch result {
            case .success(let amount):
                completion(.success(Mutez(amount)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        sendRPC(endpoint: endpoint, method: .get, completion: rpcCompletion)
    }

    /** Retrieve the address counter for the given address. */
    public func status(of address: String, completion: @escaping RPCCompletion<ContractStatus>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /** Retrieve the delegate of a given address. */
    public func delegate(of address: String, completion: @escaping RPCCompletion<String>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/delegate"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /** Retrieve the address counter for the given address. */
    public func counter(of address: String, completion: @escaping RPCCompletion<Int>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/counter"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /// Retrieve the expected quorum.
    public func currentQuorum(completion: @escaping RPCCompletion<Int>) {
        let endpoint = "/chains/main/blocks/head/votes/current_quorum"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /// Retrieve the expected quorum.
    public func currentPeriodKind(completion: @escaping RPCCompletion<PeriodKind>) {
        let endpoint = "/chains/main/blocks/head/votes/current_period_kind"
        let rpcCompletion: RPCCompletion<String> = { result in
            switch result {
            case .success(let periodKindString):
                guard let periodKind = PeriodKind(rawValue: periodKindString) else { completion(.failure(.decryptionFailed(reason: .unknown))); return }
                completion(.success(periodKind))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        sendRPC(endpoint: endpoint, method: .get, completion: rpcCompletion)
    }

    /// Sum of ballots cast so far during a voting period.
    public func ballotsSum(completion: @escaping RPCCompletion<BallotsSum>) {
        let endpoint = "/chains/main/blocks/head/votes/ballots"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /// List of delegates with their voting weight, in number of rolls
    public func delegatesList(completion: @escaping RPCCompletion<[DelegateStatus]>) {
        let endpoint = "/chains/main/blocks/head/votes/listings"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /**
     Transact Tezos between accounts.

     - Parameter amount: The amount of Tezos to send.
     - Parameter recipientAddress: The address which will receive the balance.
     - Parameter from: Wallet to send Tezos from.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     - Parameter completion: A completion block which will be called with a string representing the transaction ID hash if the operation was successful.
     */
    public func send(amount: TezToken,
                                   to recipientAddress: String,
                                   from wallet: Wallet,
                                   operationFees: OperationFees? = nil,
                                   completion: @escaping RPCCompletion<String>) {
        let transactionOperation = TransactionOperation(amount: amount, source: wallet.address, destination: recipientAddress, operationFees: operationFees)
        forgeSignPreapplyAndInjectOperation(operation: transactionOperation,
                                            source: wallet.address,
                                            keys: wallet.keys,
                                            completion: completion)
    }

    /**
     Transact Tezos between accounts with input.

     - Parameter amount: The amount of Tezos to send.
     - Parameter recipientAddress: The address which will receive the balance.
     - Parameter wallet: Wallet to send Tezos from.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     - Parameter completion: A completion block which will be called with a string representing the transaction ID hash if the operation was successful.
     - Parameter input: Input (parameter) to send to contract.
     */
    public func send<T: Encodable>(amount: TezToken,
		to recipientAddress: String,
        from wallet: Wallet,
        input: T,
        operationFees: OperationFees? = nil,
		completion: @escaping RPCCompletion<String>) {
		let transactionOperation =
            ContractOperation(amount: amount, source: wallet.address, destination: recipientAddress, input: input)
		forgeSignPreapplyAndInjectOperation(operation: transactionOperation,
			source: wallet.address,
			keys: wallet.keys,
			completion: completion)
	}

    /**
     Originate a new account from the given account.

     - Parameter initialBalance: Initial balance to create new account with
     - Parameter managerAddress: The address which will manage the new account. Defaults to wallet.
     - Parameter wallet: The wallet to use to sign the operation for the address.
     - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
     - Parameter completion: A completion block which will be called with a string representing the
     transaction ID hash if the operation was successful.
     */
    public func originateAccount(initialBalance: TezToken,
                                 managerAddress: String? = nil,
                                 from wallet: Wallet,
                                 operationFees: OperationFees? = nil,
                                 completion: @escaping RPCCompletion<String>) {
        let originateAccountOperation = OriginateAccountOperation(initialBalance: initialBalance, managerAddress: managerAddress, source: wallet, operationFees: operationFees)
        forgeSignPreapplyAndInjectOperation(operation: originateAccountOperation,
                                            source: wallet.address,
                                            keys: wallet.keys,
                                            completion: completion)
    }

    /**
     Delegate the balance of an originated account.

     Note that only KT1 accounts can delegate. TZ1 accounts are not able to delegate. This invariant is not checked on an input to this methods. Thus, the source address must be a KT1 address and he keys to sign the operation for the address are the keys used to manage the TZ1 address.

     - Parameter source: The address sending the tezos.
     - Parameter delegate: Delegate's address.
     - Parameter keys: The keys to use to sign the operation for the address.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     - Parameter completion: A completion block which will be called with a string representing the transaction ID hash if the operation was successful.
     */
	public func delegate(from source: String,
		to delegate: String,
		keys: Keys,
        operationFees: OperationFees? = nil,
		completion: @escaping RPCCompletion<String>) {
        let delegationOperation = DelegationOperation(source: source, to: delegate, operationFees: operationFees)
		forgeSignPreapplyAndInjectOperation(operation: delegationOperation,
			source: source,
			keys: keys,
			completion: completion)
	}

	/**
     Register an address as a delegate.

     - Parameter recipientAddress: The address which will receive the balance.
     - Parameter keys: The keys to use to sign the operation for the address.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     - Parameter completion: A completion block which will be called with a string representing the
     transaction ID hash if the operation was successful.
   */
	public func registerDelegate(delegate: String, keys: Keys, operationFees: OperationFees? = nil, completion: @escaping RPCCompletion<String>) {
        let registerDelegateOperation = RegisterDelegateOperation(delegate: delegate, operationFees: operationFees)
		forgeSignPreapplyAndInjectOperation(operation: registerDelegateOperation,
			source: delegate,
			keys: keys,
			completion: completion)
	}

    /**
     Clear the delegate of an originated account.
     
     - Parameter wallet: The wallet which is removing the delegate.
     - Parameter operationFees: to include in the transaction if the call is being made to a smart contract.
     - Parameter completion: A completion block which will be called with a string representing the
     transaction ID hash if the operation was successful.
     */
    public func undelegate(wallet: Wallet,
                           operationFees: OperationFees? = nil,
                           completion: @escaping RPCCompletion<String>) {
        let undelegateOperation = UndelegateOperation(source: wallet.address, operationFees: operationFees)
        forgeSignPreapplyAndInjectOperation(operation: undelegateOperation,
                                            source: wallet.address,
                                            keys: wallet.keys,
                                            completion: completion)
    }

	/**
     Forge, sign, preapply and then inject a single operation.

     - Parameter operation: The operation which will be used to forge the operation.
     - Parameter source: The address performing the operation.
     - Parameter keys: The keys to use to sign the operation for the address.
     - Parameter completion: A completion block that will be called with the results of the operation.
   */
	public func forgeSignPreapplyAndInjectOperation(operation: Operation,
		source: String,
		keys: Keys,
        completion: @escaping RPCCompletion<String>) {
		forgeSignPreapplyAndInjectOperations(operations: [operation],
			source: source,
			keys: keys,
			completion: completion)
	}

    /**
     Forge, sign, preapply and then inject a set of operations.

     Operations are processed in the order they are placed in the operation array.

     - Parameter operations: The operations which will be used to forge the operations.
     - Parameter source: The address performing the operation.
     - Parameter keys: The keys to use to sign the operation for the address.
     - Parameter completion: A completion block that will be called with the results of the operation.
     */
	public func forgeSignPreapplyAndInjectOperations(operations: [Operation],
		source: String,
		keys: Keys,
        completion: @escaping RPCCompletion<String>) {
        metadataForOperation(address: source, completion: { [weak self] result in
            switch result {
            case .success(let operationMetadata):
                let operationsWithReveal: [Operation]
                // Determine if the address performing the operations has been revealed. If it has not been,
                // check if any of the operations to perform requires the address to be revealed. If so,
                // prepend a reveal operation to the operations to perform.
                let revealOperations = operations.filter { $0.requiresReveal }
                if operationMetadata.key == nil, !revealOperations.isEmpty {
                    let revealOperation = RevealOperation(from: source, publicKey: keys.publicKey)
                    operationsWithReveal = [revealOperation] + operations
                } else {
                    operationsWithReveal = operations
                }

                // Process all operations to have increasing counters and place them in the contents array.
                let contents: [Operation] = operationsWithReveal.enumerated().map {
                    $1.counter = operationMetadata.addressCounter + $0 + 1
                    return $1
                }

                let operationPayload = OperationPayload(contents: contents, branch: operationMetadata.headHash)

                self?.forgeAndSignOperation(chainId: operationMetadata.chainId, headHash: operationMetadata.headHash, operationPayload: operationPayload, keys: keys, completion: { result in
                    switch result {
                    case .success (let signingResult):
                        self?.preapplyAndInjectOperation(operationPayload: operationPayload, operationMetadata: operationMetadata, signingResult: signingResult, source: source, keys: keys, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        })
	}

    /// Forge operation
    private func forgeOperation(chainId: String, headHash: String, operationPayload: OperationPayload, completion: @escaping RPCCompletion<String>) {
        let endpoint = "/chains/" + chainId + "/blocks/" + headHash + "/helpers/forge/operations"
        sendRPC(endpoint: endpoint, method: .post, payload: operationPayload, completion: completion)
    }

    /// Sign operation
    private func signOperation(operationPayload: OperationPayload, forgedOperation: String, keys: Keys) throws -> OperationSigningResult {
        guard let operationSigningResult = Crypto.signForgedOperation(operation: forgedOperation, secretKey: keys.secretKey) else { throw TezosError.injectError(reason: .jsonSigningFailed) }
            return operationSigningResult
    }

    /// First forge operation then sign the result
    private func forgeAndSignOperation(chainId: String, headHash: String, operationPayload: OperationPayload, keys: Keys, completion: @escaping (Result<OperationSigningResult, TezosError>) -> Void) {
        forgeOperation(chainId: chainId, headHash: headHash, operationPayload: operationPayload, completion: { [weak self] result in
            switch result {
            case .success(let forgeResult):
                do {
                    // Return successfully signed operation
                    guard let signingResult: OperationSigningResult = try self?.signOperation(operationPayload: operationPayload, forgedOperation: forgeResult, keys: keys) else {
                        completion(.failure(.injectError(reason: .forgeError)))
                        return
                    }
                    completion(.success(signingResult))
                } catch let error {
                    let unwrappedError = error as? TezosError ?? TezosError.injectError(reason: .jsonSigningFailed)
                    completion(.failure(unwrappedError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    /**
     Sign the result of a forged operation, preapply and inject it if successful.

     - Parameter operationPayload: The operation payload which was used to forge the operation.
     - Parameter operationMetadata: Metadata related to the operation.
     - Parameter source: A completion block which will be called with a string representing the transaction ID hash if the operation was successful.
     - Parameter keys: The keys to use to sign the operation for the address.
     - Parameter completion: A completion block that will be called with the results of the operation.
     */
	private func preapplyAndInjectOperation(operationPayload: OperationPayload,
		operationMetadata: OperationMetadata,
        signingResult: OperationSigningResult,
		source: String,
		keys: Keys,
		completion: @escaping RPCCompletion<String>) {
        let runOperationPayload = SignedRunOperationPayload(contents: operationPayload.contents, branch: operationPayload.branch, signature: signingResult.edsig)
        guard let jsonSignedBytes = signingResult.jsonSignedBytes else { completion(.failure(.injectError(reason: .jsonSigningFailed))); return }
        self.estimateGas(payload: runOperationPayload, signedBytesForInjection: jsonSignedBytes, operationMetadata: operationMetadata, completion: { [weak self] result in
            switch result {
            case .success():
                self?.forgeAndSignOperation(chainId: operationMetadata.chainId, headHash: operationMetadata.headHash, operationPayload: operationPayload, keys: keys, completion: { [weak self] result in
                    guard let self = self else { completion(.failure(.injectError(reason: .forgeError))); return }
                    switch result {
                    case .success(let signingResult):
                        let signedOperationPayload = SignedOperationPayload(contents: operationPayload.contents, branch: operationPayload.branch, protocol: operationMetadata.protocolHash, signature: signingResult.edsig)
                        guard let jsonSignedBytes = signingResult.jsonSignedBytes else { completion(.failure(.injectError(reason: .jsonSigningFailed))); return }
                        self.preapplyAndInjectRPC(payload: [signedOperationPayload],
                                                   signedBytesForInjection: jsonSignedBytes,
                                                   operationMetadata: operationMetadata,
                                                   completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })

            case .failure(let error):
                completion(.failure(error))
            }
        })
	}

    /// Estimate gas to properly estimate fees (run operation with RPC)
    public func estimateGas(payload: SignedRunOperationPayload,
                             signedBytesForInjection: String,
                             operationMetadata: OperationMetadata,
                             completion: @escaping (Result<Void, TezosError>) -> Void) {
        let payloadWithFees = SignedRunOperationPayload(contents: payload.contents.filter { $0.defaultFees }, branch: payload.branch, signature: payload.signature)
        guard !payloadWithFees.contents.isEmpty else {
            completion(.success(()))
            return
        }

        payloadWithFees.contents.forEach { $0.operationFees = Operation.defaultMaxFees }
        let rpcCompletion: RPCCompletion<OperationContents> = { [weak self] result in
            switch result {
            case .success(let value):
                self?.modifyFees(of: payloadWithFees, with: value.contents, operationBytesString: signedBytesForInjection)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        let endpoint = "chains/main/blocks/head/helpers/scripts/run_operation"
        sendRPC(endpoint: endpoint, method: .post, payload: payloadWithFees, completion: rpcCompletion)
    }

    private func modifyFees(of payload: SignedRunOperationPayload, with contents: [OperationStatus], operationBytesString: String) {
        contents.forEach { operation in
            guard let consumedGas = operation.metadata.operationResult.consumedGas else { return }
            let gasLimit = consumedGas + Mutez(100)
            let operationBytes = operationBytesString.lengthOfBytes(using: .ascii)
            // TODO: Check if account exists, if yes, storage limit should be zero
            let operationFees = OperationFees(fee: Mutez(operationBytes) + Mutez(Int(Double(gasLimit.amount) * 0.1)) + Mutez(100), gasLimit: gasLimit, storageLimit: Mutez(257))
            payload.contents.first { $0.counter == operation.counter }?.operationFees = operationFees
        }
    }

    /**
     Preapply an operation and inject the operation if successful.

     - Parameter payload: A JSON encoded string that will be preapplied.
     - Parameter signedBytesForInjection: A JSON encoded string that contains signed bytes for the preapplied operation.
     - Parameter operationMetadata: Metadata related to the operation.
     - Parameter completion: A completion block that will be called with the results of the operation.
     */
	private func preapplyAndInjectRPC(payload: [SignedOperationPayload],
		signedBytesForInjection: String,
		operationMetadata: OperationMetadata,
		completion: @escaping RPCCompletion<String>) {
        let rpcCompletion: RPCCompletion<[OperationContents]> = { [weak self] result in
            switch result {
            case .success(let operationContents):
                // If any operation has error status, return the first error
                let operationErrors: [InjectReason] = operationContents
                    .flatMap {
                    $0.contents.compactMap {
                        if case .failed(let error) = $0.metadata.operationResult.operationResultStatus {
                            return error
                        } else {
                            return nil
                        }
                    }
                }
                if operationErrors.isEmpty {
                    self?.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
                } else if let firstOperationError = operationErrors.first {
                    completion(.failure(.injectError(reason: firstOperationError)))
                } else {
                    completion(.failure(.injectError(reason: .unknown(message: ""))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        let endpoint = "chains/" + operationMetadata.chainId + "/blocks/" + operationMetadata.headHash + "/helpers/preapply/operations"
        sendRPC(endpoint: endpoint, method: .post, payload: payload, completion: rpcCompletion)
	}

    /**
     Send an injection RPC.

     - Parameter payload: A JSON compatible string representing the singed operation bytes.
     - Parameter completion: A completion block that will be called with the results of the operation.
     */
    private func sendInjectionRPC(payload: String, completion: @escaping RPCCompletion<String>) {
        let endpoint = "/injection/operation"
        sendRPC(endpoint: endpoint, method: .post, payload: payload, completion: { result in
            completion(result)
        })
	}

    /**
     Send an RPC as a GET or POST request.

     - Parameter endpoint: RPC endpoint
     - Parameter method: HTTP Method, defaults to get
     - Parameter payload: Payload sent
     - Parameter completion: A completion block that will be called with the results of RPC call.
     */
    public func sendRPC<T: Decodable>(endpoint: String, method: HTTPMethod = .get, payload: Encodable? = nil, completion: @escaping RPCCompletion<T>) {
        guard let remoteNodeEndpoint = URL(string: endpoint, relativeTo: remoteNodeURL) else {
            completion(.failure(.rpcFailure(reason: .invalidNode)))
            return
        }

        var urlRequest = URLRequest(url: remoteNodeEndpoint)

        let dataLog = OSLog(subsystem: subsystem, category: "Data Flow")

        if method == .post {
            do {
                guard let payload = payload else { return }
                let jsonData: Data
                if let stringPayload = payload as? String, let stringData = stringPayload.data(using: .utf8) {
                    jsonData = stringData
                } else {
                    jsonData = try payload.toJSONData()
                }
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.cachePolicy = .reloadIgnoringCacheData
                urlRequest.httpBody = jsonData
                os_log("Endnode: %@", log: dataLog, remoteNodeEndpoint.absoluteString)
                os_log("JSON data payload: %@", log: dataLog, String(data: jsonData, encoding: .utf8) ?? "")
            }
            catch let error {
                completion(.failure(.encryptionFailed(reason: error)))
                return
            }
        }

        sendRequest(urlRequest, remoteNodeEndpoint: remoteNodeEndpoint, completion: completion)
    }

    // Send the actual request specified in sendRPC
    private func sendRequest<T: Decodable>(_ urlRequest: URLRequest, remoteNodeEndpoint: URL, completion: @escaping RPCCompletion<T>) {
        let dataLog = OSLog(subsystem: subsystem, category: "Data Flow")

        urlSession.loadData(with: urlRequest) { [weak self] data, response, error in
            os_log("Endnode: %@", log: dataLog, remoteNodeEndpoint.absoluteString)
            os_log("JSON response: %@", log: dataLog, String(data: data ?? Data(), encoding: .utf8) ?? "")
            guard let self = self else {
                completion(.failure(.rpcFailure(reason: .unknown(message: ""))))
                return
            }
            do {
                let decodedObject: T = try self.rpcResponseHandler.handleResponse(data: data, response: response, error: error)
                completion(.success(decodedObject))
            } catch let error {
                let unwrappedError = error as? TezosError ?? TezosError.rpcFailure(reason: .unknown(message: ""))
                completion(.failure(unwrappedError))
            }
        }
    }

	/**
     Retrieve metadata needed to forge / pre-apply / sign / inject an operation.

     This method parallelizes fetches to get chain and address data and returns all required data
     together as an OperationData object.
   */
    private func metadataForOperation(address: String, completion: @escaping (Result<OperationMetadata, TezosError>) -> Void) {
		let fetchersGroup = DispatchGroup()

        // Send RPCs and wait for results

		// Fetch data about the chain being operated on.
		var chainId: String? = nil
		var headHash: String? = nil
		var protocolHash: String? = nil

        fetchersGroup.enter()
        chainHead(completion: { result in
            // TODO: Handle errors (below as well)
            chainId = result.value?.chainId
            headHash = result.value?.hash
            protocolHash = result.value?.protocol
            fetchersGroup.leave()
        })

        fetchersGroup.enter()
        // Fetch data about the address being operated on.
        var operationCounter: Int? = nil
        counter(of: address, completion: { result in
            operationCounter = result.value
            fetchersGroup.leave()
        })


        fetchersGroup.enter()
		// Fetch data about the key.
		var addressKey: String? = nil
        managerAddressKey(of: address, completion: { result in
            addressKey = result.value?.key
            fetchersGroup.leave()
        })

        fetchersGroup.notify(queue: DispatchQueue.main, execute: {
            // Return fetched data as an OperationData if all data was successfully retrieved.
            if let operationCounter = operationCounter,
                let headHash = headHash,
                let chainId = chainId,
                let protocolHash = protocolHash {
                let operationMetadata = OperationMetadata(chainId: chainId,
                                                          headHash: headHash,
                                                          protocolHash: protocolHash,
                                                          addressCounter: operationCounter,
                                                          key: addressKey)
                completion(.success(operationMetadata))
            } else {
                completion(.failure(.injectError(reason: .missingMetadata)))
            }
        })
	}
}

// Taken from: https://stackoverflow.com/questions/51058292/why-can-not-use-protocol-encodable-as-a-type-in-the-func#51058460
private extension Encodable {
    func toJSONData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
