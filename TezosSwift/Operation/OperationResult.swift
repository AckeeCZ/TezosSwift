//
//  OperationResult.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/17/18.
//

import Foundation

enum OperationResultStatus {
    case failed(error: PreapplyError)
    case applied
}

enum OperationResultStatusValue: String, Codable {
    case failed
    case applied
}

public enum OperationErrorKind: String, Codable {
    case temporary
    case branch
    case permanent
}

public struct PreapplyError: Codable {
    public let kind: OperationErrorKind
    public let id: String
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        consumedGas = try container.decodeIfPresent(Mutez.self, forKey: .consumedGas)
        let status = try container.decode(OperationResultStatusValue.self, forKey: .status)
        switch status {
        case .applied:
            operationResultStatus = .applied
        case .failed:
            var errorsUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .errors)
            let preapplyReasonError = try errorsUnkeyedContainer.decode(PreapplyError.self)
            operationResultStatus = .failed(error: preapplyReasonError)
        }
    }
}

