//
//  ManagerKey.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/7/18.
//

import Foundation

/// Manager key data 
public struct ManagerKey: Codable {
    public let manager: String
    public let key: String?
}
