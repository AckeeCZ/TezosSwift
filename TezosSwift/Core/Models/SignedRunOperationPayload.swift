//
//  SignedRunOperationPayload.swift
//  TezosSwift
//
//  Created by Marek Fořt on 12/13/18.
//

import Foundation

/// Signed operation's data
public struct SignedRunOperationPayload: Encodable {
    public var contents: [Operation]
    public let branch: String
    public let signature: String

    public init(contents: [Operation], branch: String, signature: String) {
        self.contents = contents
        self.branch = branch
        self.signature = signature 
    }
}

