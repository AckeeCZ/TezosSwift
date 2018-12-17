//
//  OperationResult.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/17/18.
//

import Foundation

struct OperationResult {
    let consumedGas: Mutez
}

extension OperationResult: Decodable {
    private enum CodingKeys: String, CodingKey {
        case consumedGas
        case status
        case storageSize
        case storage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.consumedGas = try container.decode(Mutez.self, forKey: .consumedGas)
    }
}

