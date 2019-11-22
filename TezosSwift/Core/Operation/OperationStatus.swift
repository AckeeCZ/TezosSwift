//
//  OperationStatus.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/17/18.
//

import Foundation

struct OperationStatus {
    let counter: Int
    let metadata: Metadata
}

extension OperationStatus: Decodable {
    private enum CodingKeys: String, CodingKey {
        case counter
        case metadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.counter = try container.decodeRPC(Int.self, forKey: .counter)
        self.metadata = try container.decode(Metadata.self, forKey: .metadata)
    }
}
