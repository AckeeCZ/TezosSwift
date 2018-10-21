import Foundation

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
 * object that
 * conforms the the TezosRPC protocol and calling:
 *      func forgeSignPreapplyAndInjectOperation(operation: Operation,
 *                                               address: String,
 *                                               secretKey: String,
 *                                               completion: @escaping (String?, Error?) -> Void)
 */
public class TezosClient {
  /** The default node URL to use. */
  public static let defaultNodeURL = URL(string: "https://rpc.tezrpc.me")!

  /** The URL session that will be used to manage URL requests. */
	private let urlSession: URLSession

  /** A URL pointing to a remote node that will handle requests made by this client. */
	private let remoteNodeURL: URL

  /**
   * Initialize a new TezosClient using the default Node URL.
   */
  public convenience init() {
    self.init(remoteNodeURL: type(of: self).defaultNodeURL)
  }

  /**
   * Initialize a new TezosClient.
   *
   * @param removeNodeURL The path to the remote node.
   */
	public init(remoteNodeURL: URL) {
		self.remoteNodeURL = remoteNodeURL
		self.urlSession = URLSession.shared
	}

  /** Retrieve data about the chain head. */
	public func getHead(completion: @escaping ([String: Any]?, Error?) -> Void) {
		let rpc = GetChainHeadRPC(completion: completion)
		self.send(rpc: rpc)
	}

  /** Retrieve the balance of a given wallet. */
	public func getBalance(wallet: Wallet, completion: @escaping (TezosBalance?, Error?) -> Void) {
		self.getBalance(address: wallet.address, completion: completion)
	}

  /** Retrieve the balance of a given address. */
	public func getBalance(address: String, completion: @escaping (TezosBalance?, Error?) -> Void) {
		let rpc = GetAddressBalanceRPC(address: address, completion: completion)
		self.send(rpc: rpc)
	}

  /** Retrieve the delegate of a given wallet. */
	public func getDelegate(wallet: Wallet, completion: @escaping (String?, Error?) -> Void) {
		self.getDelegate(address: wallet.address, completion: completion)
	}

  /** Retrieve the delegate of a given address. */
	public func getDelegate(address: String, completion: @escaping (String?, Error?) -> Void) {
		let rpc = GetDelegateRPC(address: address, completion: completion)
		self.send(rpc: rpc)
	}

  /** Retrieve the hash of the block at the head of the chain. */
	public func getHeadHash(completion: @escaping (String?, Error?) -> Void) {
		let rpc = GetChainHeadHashRPC(completion: completion)
		self.send(rpc: rpc)
	}

  /** Retrieve the address counter for the given address. */
	public func getAddressCounter(address: String, completion: @escaping (Int?, Error?) -> Void) {
		let rpc = GetAddressCounterRPC(address: address, completion: completion)
		self.send(rpc: rpc)
	}

  /** Retrieve the address manager key for the given address. */
	public func getAddressManagerKey(address: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
		let rpc = GetAddressManagerKeyRPC(address: address, completion: completion)
		self.send(rpc: rpc)
	}

  /**
   * Transact Tezos between accounts.
   *
   * @param balance The balance to send.
   * @param recipientAddress The address which will receive the balance.
   * @param wallet The wallet which will send the balance.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
	public func send(amount: TezosBalance,
		to recipientAddress: String,
		from wallet: Wallet,
		completion: @escaping (String?, Error?) -> Void) {
		let transactionOperation =
			TransactionOperation(amount: amount, source: wallet, destination: recipientAddress)
		self.forgeSignPreapplyAndInjectOperation(operation: transactionOperation,
			wallet: wallet,
			completion: completion)
	}

	/**
   * Forge, sign, preapply and then inject an operation.
   *
   * @param operation The operation which will be used to forge the operation.
   * @param wallet The wallet which will send the balance.
   * @param completion A completion block that will be called with the results of the operation.
   */
	public func forgeSignPreapplyAndInjectOperation(operation: Operation,
		wallet: Wallet,
		completion: @escaping (String?, Error?) -> Void) {
		guard let operationMetadata = getMetadataForOperation(address: wallet.address) else {
			let error = TezosClientError(kind: .unknown, underlyingError: nil)
			completion(nil, error)
			return
		}

		let newCounter = String(operationMetadata.addressCounter + 1)

		var mutableOperation = operation.dictionaryRepresentation
		mutableOperation["counter"] = newCounter

		var operationPayload: [String: Any] = [:]
		operationPayload["contents"] = [mutableOperation]
		operationPayload["branch"] = operationMetadata.headHash

		guard let jsonPayload = JSONUtils.jsonString(for: operationPayload) else {
      let error = TezosClientError(kind: .unexpectedRequestFormat, underlyingError: nil)
			completion(nil, error)
			return
		}

		let forgeRPC = ForgeOperationRPC(chainID: operationMetadata.chainID,
			headHash: operationMetadata.headHash,
			payload: jsonPayload) { (result, error) in
			guard let result = result else {
				completion(nil, error)
				return
			}
			self.signPreapplyAndInjectOperation(operationPayload: operationPayload,
        operationMetadata: operationMetadata,
				forgeResult: result,
				secretKey: wallet.secretKey,
				completion: completion)
		}
		self.send(rpc: forgeRPC)
	}

	/**
   * Sign the result of a forged operation, preapply and inject it if successful.
   *
   * @param operationPayload The operation payload which was used to forge the operation.
   * @param operationMetadata Metadata related to the operation.
   * @param forgeResult The result of forging the operation payload.
   * @param secretKey The edsk prefixed secret key which will be used to sign the operation.
   * @param completion A completion block that will be called with the results of the operation.
   */
	private func signPreapplyAndInjectOperation(operationPayload: [String: Any],
    operationMetadata: OperationMetadata,
		forgeResult: String,
		secretKey: String,
		completion: @escaping (String?, Error?) -> Void) {
		guard let signedResult = Crypto.signForgedOperation(operation: forgeResult,
			secretKey: secretKey),
			let jsonSignedBytes = JSONUtils.jsonString(for: signedResult.signedOperation) else {
        let error = TezosClientError(kind: .unknown, underlyingError: nil)
				completion(nil, error)
				return
		}

		var mutableOperationPayload = operationPayload
		mutableOperationPayload["signature"] = signedResult.edsig
		mutableOperationPayload ["protocol"] = operationMetadata.protocolHash

		let operationPayloadArray = [mutableOperationPayload]
		guard let signedJsonPayload = JSONUtils.jsonString(for: operationPayloadArray) else {
      let error = TezosClientError(kind: .unexpectedRequestFormat, underlyingError: nil)
			completion(nil, error)
			return
		}

		self.preapplyAndInjectRPC(payload: signedJsonPayload,
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
	private func preapplyAndInjectRPC(payload: String,
		signedBytesForInjection: String,
		operationMetadata: OperationMetadata,
		completion: @escaping (String?, Error?) -> Void) {
		let preapplyOperationRPC = PreapplyOperationRPC(chainID: operationMetadata.chainID,
			headHash: operationMetadata.headHash,
			payload: payload,
			completion: { (result, error) in
				guard let _ = result else {
					completion(nil, error)
					return
				}

				self.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
			})
		self.send(rpc: preapplyOperationRPC)
	}

	/**
   * Send an injection RPC.
   *
   * @param payload A JSON compatible string representing the singed operation bytes.
   * @param completion A completion block that will be called with the results of the operation.
   */
	private func sendInjectionRPC(payload: String, completion: @escaping (String?, Error?) -> Void) {
		let injectRPC = InjectionRPC(payload: payload, completion: { (txHash, txError) in
			completion(txHash, txError)
		})

		self.send(rpc: injectRPC)
	}

	/**
   * Send an RPC as a GET or POST request.
   */
	public func send<T>(rpc: TezosRPC<T>) {
		guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: self.remoteNodeURL) else {
      let error = TezosClientError(kind: .unknown, underlyingError: nil)
			rpc.handleResponse(data: nil, error: error)
			return
		}

		var urlRequest = URLRequest(url: remoteNodeEndpoint)

		if rpc.isPOSTRequest,
			let payload = rpc.payload,
			let payloadData = payload.data(using: .utf8) {
			urlRequest.httpMethod = "POST"
			urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
			urlRequest.cachePolicy = .reloadIgnoringCacheData
			urlRequest.httpBody = payloadData
		}

		let request = self.urlSession.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
      if let httpResp = urlRequest as? HTTPURLResponse, httpResp.statusCode != 200 {
        print("very wrong")
      }

			rpc.handleResponse(data: data, error: error)
		}
		request.resume()
	}

	/**
   * Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
   *
   * This method parallelizes fetches to get chain and address data and returns all required data
   * together as an OperationData object.
   */
	private func getMetadataForOperation(address: String) -> OperationMetadata? {
		let fetchersGroup = DispatchGroup()

    // Fetch data about the chain being operated on.
		var chainID: String? = nil
		var headHash: String? = nil
		var protocolHash: String? = nil
		let chainHeadRequestRPC = GetChainHeadRPC() { (json, error) in
			if let json = json,
				let fetchedChainID = json["chain_id"] as? String,
				let fetchedHeadHash = json["hash"] as? String,
				let fetchedProtocolHash = json["protocol"] as? String {
				chainID = fetchedChainID
				headHash = fetchedHeadHash
				protocolHash = fetchedProtocolHash
			}
			fetchersGroup.leave()
		}

    // Fetch data about the address being operated on.
		var operationCounter: Int? = nil
		let getAddressCounterRPC =
			GetAddressCounterRPC(address: address) { (fetchedOperationCounter, error) in
				if let fetchedOperationCounter = fetchedOperationCounter {
					operationCounter = fetchedOperationCounter
				}
				fetchersGroup.leave()
		}

    // Fetch data about the key.
    var addressKey: String? = nil
    let getAddressManagerKeyRPC = GetAddressManagerKeyRPC(address: address) { (fetchedManagerAndKey, error) in
      if let fetchedManagerAndKey = fetchedManagerAndKey,
         let fetchedKey = fetchedManagerAndKey["key"] as? String {
         addressKey = fetchedKey
      }
      fetchersGroup.leave()
    }

    // Send RPCs and wait for results
		fetchersGroup.enter()
		self.send(rpc: chainHeadRequestRPC)

		fetchersGroup.enter()
		self.send(rpc: getAddressCounterRPC)

    fetchersGroup.enter()
    self.send(rpc: getAddressManagerKeyRPC)

		fetchersGroup.wait()

		// Return fetched data as an OperationData if all data was successfully retrieved.
		if let operationCounter = operationCounter,
       let headHash = headHash,
       let chainID = chainID,
 			 let protocolHash = protocolHash {
      return OperationMetadata(chainID: chainID,
                               headHash: headHash,
                               protocolHash: protocolHash,
                               addressCounter: operationCounter,
                               key: addressKey)
		}
		return nil
	}
}
