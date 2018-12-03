import Foundation
import Result
import os

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

public typealias ResultCompletion<T> = (Result<T, TezosError>) -> Void
public typealias RPCCompletion<T: Decodable> = (Result<T, TezosError>) -> Void

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

public class TezosClient {

	/** The URL session that will be used to manage URL requests. */
	private let urlSession: NetworkSession

	/** A URL pointing to a remote node that will handle requests made by this client. */
	private let remoteNodeURL: URL

    private let subsystem = "ackee.TezosSwift.TezosClient"

	/**
   * Initialize a new TezosClient.
   *
   * @param removeNodeURL The path to the remote node.
   */
    public init(remoteNodeURL: URL) {
        self.remoteNodeURL = remoteNodeURL
        self.urlSession = URLSession.shared
    }

    // Internal init for unit testing
    public init(remoteNodeURL: URL, urlSession: NetworkSession = URLSession.shared) {
        self.remoteNodeURL = remoteNodeURL
        self.urlSession = urlSession
    }

    /** Retrieve data about the chain head. */
    public func chainHead(completion: @escaping RPCCompletion<ChainHead>) {
        let endpoint = "/chains/main/blocks/head"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    public struct ManagerKey: Codable {
        let manager: String
        let key: String?
    }

    public func managerAddressKey(of address: String, completion: @escaping RPCCompletion<ManagerKey>) {
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/manager_key"
        sendRPC(endpoint: endpoint, method: .get, completion: completion)
    }

    /** Retrieve the balance of a given address. */
    public func balance(of address: String, completion: @escaping (Result<Tez, TezosError>) -> Void) {
        let rpcCompletion: (Result<Double, TezosError>) -> Void = { result in
            if let balance = result.value {
                completion(.success(Tez(balance)))
            } else if let error = result.error {
                completion(.failure(error))
            } else {
                completion(.failure(.unknown(message: "Balance failed.")))
            }
        }
        let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
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

	/**
   * Transact Tezos between accounts.
   *
   * @param balance The balance to send.
   * @param recipientAddress The address which will receive the balance.
   * @param source The address sending the balance.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
    public func send(amount: TezToken,
                                   to recipientAddress: String,
                                   from wallet: Wallet,
                                   completion: @escaping RPCCompletion<String>) {
        let transactionOperation =
            TransactionOperation(amount: amount, source: wallet.address, destination: recipientAddress)
        forgeSignPreapplyAndInjectOperation(operation: transactionOperation,
                                            source: wallet.address,
                                            keys: wallet.keys,
                                            completion: completion)
    }


    public func send<T: Encodable>(amount: TezToken,
		to recipientAddress: String,
        from wallet: Wallet,
        input: T,
		completion: @escaping RPCCompletion<String>) {
		let transactionOperation =
            ContractOperation(amount: amount, source: wallet.address, destination: recipientAddress, input: input)
		forgeSignPreapplyAndInjectOperation(operation: transactionOperation,
			source: wallet.address,
			keys: wallet.keys,
			completion: completion)
	}

	/**
   * Delegate the balance of an originated account.
   *
   * Note that only KT1 accounts can delegate. TZ1 accounts are not able to delegate. This invariant
   * is not checked on an input to this methods. Thus, the source address must be a KT1 address and
   * the keys to sign the operation for the address are the keys used to manage the TZ1 address.
   *
   * TODO: Support clearing a delegate.
   *
   * @param recipientAddress The address which will receive the balance.
   * @param source The address sending the balance.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
	public func delegate(from source: String,
		to delegate: String,
		keys: Keys,
		completion: @escaping RPCCompletion<String>) {
		let delegationOperation = DelegationOperation(source: source, to: delegate)
		self.forgeSignPreapplyAndInjectOperation(operation: delegationOperation,
			source: source,
			keys: keys,
			completion: completion)
	}

	/**
   * Register an address as a delegate.
   *
   * @param recipientAddress The address which will receive the balance.
   * @param source The address sending the balance.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
	public func registerDelegate(delegate: String, keys: Keys, completion: @escaping RPCCompletion<String>) {
		let registerDelegateOperation = RegisterDelegateOperation(delegate: delegate)
		self.forgeSignPreapplyAndInjectOperation(operation: registerDelegateOperation,
			source: delegate,
			keys: keys,
			completion: completion)
	}

	/**
   * Forge, sign, preapply and then inject a single operation.
   *
   * @param operation The operation which will be used to forge the operation.
   * @param source The address performing the operation.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block that will be called with the results of the operation.
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
   * Forge, sign, preapply and then inject a set of operations.
   *
   * Operations are processed in the order they are placed in the operation array.
   *
   * @param operation The operation which will be used to forge the operation.
   * @param source The address performing the operation.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block that will be called with the results of the operation.
   */

	public func forgeSignPreapplyAndInjectOperations(operations: [Operation],
		source: String,
		keys: Keys,
        completion: @escaping RPCCompletion<String> ) {
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

                let rpcCompletion: RPCCompletion<String> = { [weak self] result in
                    switch result {
                    case .success(let forgeResult):
                        self?.signPreapplyAndInjectOperation(operationPayload: operationPayload, operationMetadata: operationMetadata, forgeResult: forgeResult, source: source, keys: keys, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

                let endpoint = "/chains/" + operationMetadata.chainId + "/blocks/" + operationMetadata.headHash + "/helpers/forge/operations"
                self?.sendRPC(endpoint: endpoint, method: .post, payload: operationPayload, completion: rpcCompletion)
            case .failure(let error):
                completion(.failure(error))
            }
        })
	}

	/**
   * Sign the result of a forged operation, preapply and inject it if successful.
   *
   * @param operationPayload The operation payload which was used to forge the operation.
   * @param operationMetadata Metadata related to the operation.
   * @param forgeResult The result of forging the operation payload.
   * @param source The address performing the operation.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block that will be called with the results of the operation.
   */
	private func signPreapplyAndInjectOperation(operationPayload: OperationPayload,
		operationMetadata: OperationMetadata,
		forgeResult: String,
		source: String,
		keys: Keys,
		completion: @escaping RPCCompletion<String>) {
		guard let operationSigningResult = Crypto.signForgedOperation(operation: forgeResult,
			secretKey: keys.secretKey),
			let jsonSignedBytes = JSONUtils.jsonString(for: operationSigningResult.sbytes) else {
				completion(.failure(.jsonSigningFailed))
				return
            }

        let signedOperationPayload = SignedOperationPayload(contents: operationPayload.contents, branch: operationPayload.branch, protocol: operationMetadata.protocolHash, signature: operationSigningResult.edsig)

		self.preapplyAndInjectRPC(payload: [signedOperationPayload],
			signedBytesForInjection: jsonSignedBytes,
			operationMetadata: operationMetadata,
			completion: completion)
	}

	/**
   * Preapply an operation and inject the operation if successful.
   *
   * @param payload A JSON encoded string that will be preapplied.
   * @param signedBytesForInjection A JSON encoded string that contains signed bytes for the
   *        preapplied operation.
   * @param operationMetadata Metadata related to the operation.
   * @param completion A completion block that will be called with the results of the operation.
   */
	private func preapplyAndInjectRPC(payload: Encodable,
		signedBytesForInjection: String,
		operationMetadata: OperationMetadata,
		completion: @escaping RPCCompletion<String>) {
        let rpcCompletion: RPCCompletion<String> = { [weak self] result in
            switch result {
            case .success(_):
                self?.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        let endpoint = "chains/" + operationMetadata.chainId + "/blocks/" + operationMetadata.headHash + "/helpers/preapply/operations"
        sendRPC(endpoint: endpoint, method: .post, payload: payload, completion: rpcCompletion)

	}

	/**
   * Send an injection RPC.
   *
   * @param payload A JSON compatible string representing the singed operation bytes.
   * @param completion A completion block that will be called with the results of the operation.
   */
    private func sendInjectionRPC(payload: String, completion: @escaping RPCCompletion<String>) {
        let endpoint = "/injection/operation"
        sendRPC(endpoint: endpoint, method: .post, payload: payload, completion: { result in
            completion(result)
        })
	}

	/**
   * Send an RPC as a GET or POST request.
   */
    public func sendRPC<T: Decodable>(endpoint: String, method: HTTPMethod = .get, payload: Encodable? = nil, completion: @escaping RPCCompletion<T>) {
        guard let remoteNodeEndpoint = URL(string: endpoint, relativeTo: remoteNodeURL) else {
            completion(.failure(.invalidNode))
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
                os_log("Endnode: %@", log: dataLog, endpoint)
                os_log("JSON data payload: %@", log: dataLog, String(data: jsonData, encoding: .utf8) ?? "")
            }
            catch let error {
                completion(.failure(.encryptionFailed(error: error)))
                return
            }
        }

        sendRequest(urlRequest, remoteNodeEndpoint: remoteNodeEndpoint, completion: completion)
    }

    private func sendRequest<T: Decodable>(_ urlRequest: URLRequest, remoteNodeEndpoint: URL, completion: @escaping RPCCompletion<T>) {
        let dataLog = OSLog(subsystem: subsystem, category: "Data Flow")

        urlSession.loadData(with: urlRequest) { [weak self] data, response, error in
            os_log("Endnode: %@", log: dataLog, remoteNodeEndpoint.absoluteString)
            os_log("JSON response: %@", log: dataLog, String(data: data ?? Data(), encoding: .utf8) ?? "")
            // Decode the server's response to a string in order to bundle it with the error if it is in
            // a readable format.
            var errorMessage = ""
            if let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                errorMessage = dataString
            }

            // Check if the response contained a 200 HTTP OK response. If not, then propagate an error.
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode != 200 {
                // Default to unknown error and try to give a more specific error code if it can be narrowed
                // down based on HTTP response code.
                var error: TezosError = .responseError(code: httpResponse.statusCode, message: errorMessage, data: data)
                // Status code 40X: Bad request was sent to server.
                if httpResponse.statusCode >= 400 && httpResponse.statusCode < 500 {
                    error = .unexpectedRequestFormat(message: errorMessage)
                    // Status code 50X: Bad request was sent to server.
                } else if httpResponse.statusCode >= 500 {
                    error = .unexpectedResponse(message: errorMessage)
                }

                // Drop data and send our error to let subsequent handlers know something went wrong and to
                // give up.
                completion(.failure(error))
                return
            }
            do {
                guard let self = self else { throw TezosError.decryptionFailed }
                let decodedObject: T = try self.decodeData(data)
                completion(.success(decodedObject))
            } catch let tezosError as TezosError {
                completion(.failure(tezosError))
            } catch let error {
                completion(.failure(.unknown(message: error.localizedDescription)))
            }
        }
    }

    private func decodeData<T: Decodable>(_ data: Data?) throws -> T {
        guard let data = data else {
            throw TezosError.noResponseData
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch let error {
            guard let singleResponse = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"")) else { throw TezosError.unexpectedResponseType(decodingError: error) }

            if let responseNumber = singleResponse.numberValue as? T {
                return responseNumber
            } else if let responseString = singleResponse as? T {
                return responseString
            } else {
                throw TezosError.unexpectedResponseType(decodingError: error)
            }
        }
    }

	/**
   * Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
   *
   * This method parallelizes fetches to get chain and address data and returns all required data
   * together as an OperationData object.
   */
    private func metadataForOperation(address: String, completion: @escaping (Result<OperationMetadata, TezosError>) -> Void) {
		let fetchersGroup = DispatchGroup()

        fetchersGroup.enter()

        // Send RPCs and wait for results

		// Fetch data about the chain being operated on.
		var chainId: String? = nil
		var headHash: String? = nil
		var protocolHash: String? = nil

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
                completion(.failure(.unknown(message: "Getting metadata failed")))
            }
        })
	}
}

//Taken from: https://stackoverflow.com/questions/24115141/converting-string-to-int-with-swift/46716943#46716943
private extension String {
    var numberValue: NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
}

// Taken from: https://stackoverflow.com/questions/51058292/why-can-not-use-protocol-encodable-as-a-type-in-the-func#51058460
private extension Encodable {
    func toJSONData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
