//
//  OperationPayload.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/5/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Foundation

public struct OperationPayload: Encodable {
    public let operation: OperationPayloadContent
    public let chainId: String
    
    enum CodingKeys: String, CodingKey {
        case operation
        case chainId = "chain_id"
    }
}

/// Operation's payload data
public struct OperationPayloadContent: Encodable {
    public let contents: [Operation]
    public let branch: String
}
