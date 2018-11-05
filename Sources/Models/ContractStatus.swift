//
//  ContractStatus.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/1/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

enum ContractStatusKeys: String, CodingKey {
    case balance = "balance"
    case spendable = "spendable"
}

public struct ContractStatus {
    let balance: TezosBalance
    let spendable: Bool
}

extension ContractStatus: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContractStatusKeys.self)
        let balance = try container.decode(TezosBalance.self, forKey: .balance)
        let spendable = try container.decode(Bool.self, forKey: .spendable)
        self.init(balance: balance, spendable: spendable)
    }
}

extension KeyedDecodingContainer {
    func decodeRPC(_ type: Int.Type, forKey key: K) throws -> Int {
        let intString = try decode(String.self, forKey: key)
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decryption failed")
        guard let decodedInt = Int(intString) else { throw DecodingError.dataCorrupted(context) }
        return decodedInt
    }
}


public struct ChainHead: Codable {
    let chainId: String
    let hash: String
    let `protocol`: String
}

