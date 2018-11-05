//
//  OperationPayload.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/5/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

struct OperationPayload: Encodable {
    let contents: [Operation]
    let branch: String
}
