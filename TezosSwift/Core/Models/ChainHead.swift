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
    public let chainId: String
    public let hash: String
    public let `protocol`: String
}
