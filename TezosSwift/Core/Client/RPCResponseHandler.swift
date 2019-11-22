//
//  RPCResponseHandler.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/14/18.
//

import Foundation

struct RPCResponseHandler {
    func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> T {
        guard let data = data else { throw TezosError.rpcFailure(reason: .noData) }

        // Check if the response contained a 200 HTTP OK response. If not, then propagate an error.
        try decodeResponse(response, data: data)

        return try decodeData(data)
    }

    /// Decode response and raise appropriate error if necessary
    private func decodeResponse(_ response: URLResponse?, data: Data) throws {
        // Decode the server's response to a string in order to bundle it with the error if it is in
        // a readable format.
        let jsonDecoder = JSONDecoder()
        let errorMessage = (try? jsonDecoder.decode(String.self, from: data)) ?? ""

        // Call was successful
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 else { return }

        // Default to unknown error and try to give a more specific error code if it can be narrowed
        // down based on HTTP response code.
        var error: TezosError = .rpcFailure(reason: .responseError(code: httpResponse.statusCode, message: errorMessage))
        // Status code 40X: Bad request was sent to server.
        if httpResponse.statusCode >= 400 && httpResponse.statusCode < 500 {
            error = .rpcFailure(reason: .unexpectedRequestFormat(message: errorMessage))
            // Status code 50X: Bad request was sent to server.
        } else if httpResponse.statusCode >= 500 {
            do {
                let rpcReason = try jsonDecoder.decode(RPCReason.self, from: data)
                error = .rpcFailure(reason: rpcReason)
            } catch {
                throw TezosError.rpcFailure(reason: .unknown(message: errorMessage))
            }
        }

        // Drop data and send our error to let subsequent handlers know something went wrong and to
        // give up.
        throw error
    }

    // Decode data from RPC response
    private func decodeData<T: Decodable>(_ data: Data?) throws -> T {
        guard let data = data else {
            throw TezosError.rpcFailure(reason: .noData)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch let error {
            // Could not decode data to String
            guard let singleResponse = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"")) else { throw TezosError.decryptionFailed(reason: .responseError(decodingError: error)) }
            
            // Decode number value from String
            if let responseNumber = singleResponse.numberValue as? T {
                return responseNumber
            } else if let responseString = singleResponse as? T {
                return responseString
            } else {
                throw TezosError.decryptionFailed(reason: .responseError(decodingError: error))
            }
        }
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
