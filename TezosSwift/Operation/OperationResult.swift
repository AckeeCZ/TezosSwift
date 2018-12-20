//
//  OperationResult.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/17/18.
//

import Foundation

enum OperationResultStatus {
    case failed(error: InjectReason)
    case applied
}

enum OperationResultStatusValue: String, Codable {
    case failed
    case applied
}

struct OperationResult {
    let consumedGas: Mutez?
    let operationResultStatus: OperationResultStatus
}

extension OperationResult: Decodable {
    private enum CodingKeys: String, CodingKey {
        case consumedGas
        case status
        case storageSize
        case storage
        case errors
        case id
    }

    init(from decoder: Decoder) throws {
        func decodeError(with stringError: String) -> InjectReason {
            if stringError.contains("gas_exhausted") {
                return .gasExhaustion
            } else {
                return .unknown(message: stringError)
            }
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.consumedGas = try container.decodeIfPresent(Mutez.self, forKey: .consumedGas)
        let statusError = try container.decode(OperationResultStatusValue.self, forKey: .status)
        switch statusError {
        case .applied:
            self.operationResultStatus = .applied
        case .failed:
            var errorsUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .errors)
            let stringError = try errorsUnkeyedContainer.nestedContainer(keyedBy: CodingKeys.self).decode(String.self, forKey: .id)
            let operationError = decodeError(with: stringError)
            self.operationResultStatus = .failed(error: operationError)
        }
    }
}

