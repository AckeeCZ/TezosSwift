import Foundation

/**
 * Tezos Swift Error
 */

public enum TezosError: Error {
    case unexpectedResponse(message: String)
    case unexpectedRequestFormat(message: String)
    case responseError(code: Int, message: String, data: Any?)
    case unknown(message: String)
    case noResponseData
    case unexpectedResponseType
    case jsonSigningFailed
    case invalidNode
    case unsupportedTezosType
    case encryptionFailed(error: Error)
    case decryptionFailed
    case orError
}
