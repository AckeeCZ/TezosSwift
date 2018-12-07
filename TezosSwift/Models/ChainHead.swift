//
//  ChainHead.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/5/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/// Chain's head data
public struct ChainHead: Codable {
    let chainId: String
    let hash: String
    let `protocol`: String
}
