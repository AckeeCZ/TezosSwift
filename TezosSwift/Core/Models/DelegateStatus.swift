//
//  DelegateStatus.swift
//
//
//  Created by Marek Fořt on 12/13/18.
//

import Foundation

public struct DelegateStatus {
    public let address: String
    public let rollsCount: Int
}

extension DelegateStatus: Decodable {
    private enum CodingKeys: String, CodingKey {
        case pkh
        case rolls
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self, forKey: .pkh)
        self.rollsCount = try container.decode(Int.self, forKey: .rolls)
    }
}
