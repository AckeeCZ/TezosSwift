//
//  BallotsSum.swift
//  BigInt
//
//  Created by Marek Fořt on 12/13/18.
//

import Foundation

public struct BallotsSum {
    public let nayCount: Int
    public let passCount: Int
    public let yayCount: Int
}

extension BallotsSum: Decodable {
    private enum CodingKeys: String, CodingKey {
        case nay
        case pass
        case yay
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nayCount = try container.decode(Int.self, forKey: .nay)
        self.passCount = try container.decode(Int.self, forKey: .pass)
        self.yayCount = try container.decode(Int.self, forKey: .yay)
    }
}
