//
//  SignedOperationPayload.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/5/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

/// Signed operation's data 
public struct SignedOperationPayload: Encodable {
    let contents: [Operation]
    let branch: String
    let `protocol`: String
    let signature: String
}
