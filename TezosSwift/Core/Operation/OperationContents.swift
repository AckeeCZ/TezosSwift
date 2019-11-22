//
//  OperationContents.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/17/18.
//

import Foundation

struct OperationContents {
    let contents: [OperationStatus]
}

extension OperationContents: Decodable {
    private enum CodingKeys: String, CodingKey {
        case contents
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contents = try container.decode([OperationStatus].self, forKey: .contents)
    }
}
