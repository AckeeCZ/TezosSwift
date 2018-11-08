//
//  TezosPair.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/8/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

struct TezosPair<T: Decodable, U: Decodable> {
    typealias First = T
    typealias Second = U
    let first: First
    let second: Second
}

extension TezosPair: Decodable {
    init(from decoder: Decoder) throws {

        var container = try decoder.container(keyedBy: StorageKeys.self).nestedUnkeyedContainer(forKey: .args)
        let firstContainer = try container.nestedContainer(keyedBy: StorageKeys.self)
        let secondContainer = try container.nestedContainer(keyedBy: StorageKeys.self)

        let firstPrimaryType = try firstContainer.decode(String.self, forKey: .prim).self
        if firstPrimaryType == "Pair" {
            self.first = try firstContainer.decode(First.self, forKey: .args)
        } else {
            self.first = try firstContainer.decodeRPC(First.self, forKey: .prim).self
        }

        let secondPrimaryType = try secondContainer.decode(String.self, forKey: .prim).self
        if secondPrimaryType == "Pair" {
            self.second = try secondContainer.decode(Second.self, forKey: .args)
        } else {
            self.second = try secondContainer.decodeRPC(Second.self, forKey: .prim).self
        }
    }
}
