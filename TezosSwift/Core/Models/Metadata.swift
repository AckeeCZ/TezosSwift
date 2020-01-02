//
//  Metadata.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/17/18.
//

import Foundation

struct Metadata {
    let operationResult: OperationResult
    let internalOperationResults: [InternalOperationResult]
}

extension Metadata: Decodable {
    private enum CodingKeys: String, CodingKey {
        case operationResult
        case internalOperationResults
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operationResult = try container.decode(OperationResult.self, forKey: .operationResult)
        self.internalOperationResults = try container.decodeIfPresent([InternalOperationResult].self, forKey: .internalOperationResults) ?? []
    }
}
