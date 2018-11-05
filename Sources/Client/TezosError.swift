import Foundation

/**
 * A struct representing an error that occured in the Tezos Client.
 */
//public struct TezosError: Error {
//
//    /**
//   * Enumeration representing possible kinds of errors.
//   */
//    public enum ErrorKind: String {
//        case unknown
//        case rpcError
//        case unexpectedResponse
//        case unexpectedRequestFormat
//    }
//
//    /** The error code which occurred. */
//    let kind: ErrorKind
//
//    /** The underlying error returned from a subsystem, if one exists. */
//    let underlyingError: String?
//}
//
//extension TezosError: LocalizedError {
//    public var errorDescription: String? {
//        let errorKindDesc = "TezosError: " + kind.rawValue
//        if let underlyingError = self.underlyingError {
//            return underlyingError + " (" + errorKindDesc + ")"
//        } else {
//            return errorKindDesc
//        }
//    }
//}

/**
 * Tezos Swift Error
 */

public enum TezosError: Error {
//    public enum KeyManagerFailureReason {
//        case keychainStorageFailure
//        case secureEnclaveCreationFailed
//        case encryptionFailed
//        case decryptionFailed
//        case keyNotFound
//        case signatureFailed
//        case keyDerivationFailed
//    }
//
//    public enum JSONRPCFailureReason {
//        case unsupportedVersion(String)
//        case responseMismatch(requestID: String?, responseID: String?)
//        case responseError(code: Int, message: String, data: Any?)
//        case parseError(error: Error)
//        case invalidRequestJSON
//        case unknown
//    }
//
//    public enum DataConversionFailureReason {
//        case wrongSize(expected: Int, actual: Int)
//        case scalarConversionFailed(forValue: Any, toType: Any)
//    }
//
//    public enum Web3FailureReason {
//        case parsingFailure
//    }
//
//    case keyManagerFailed(reason: KeyManagerFailureReason)
//    case jsonRPCFailed(reason: JSONRPCFailureReason)
//    case dataConversionFailed(reason: DataConversionFailureReason)
//    case web3Failure(reason: Web3FailureReason)
//    case unknown(error: Error)

//    case requestError(statusCode: Int)
//    case rpcError
//    case unexpectedResponse
//    case unexpectedRequestFormat
//    case jsonSigningFailed
//    case invalidNode
//    case rpcFailed(reason: RPCFailureReason)

    case unexpectedResponse(message: String)
    case unexpectedRequestFormat(message: String)
    case responseError(code: Int, message: String, data: Any?)
    case unknown(message: String)
    case noResponseData
    case unexpectedResponseType
    case jsonSigningFailed
    case invalidNode
}
