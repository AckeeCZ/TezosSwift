//
//  StatusDelegate.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/8/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/// Status delegate data
public struct StatusDelegate: Codable {
    public let setable: Bool
    public let value: String?
}
