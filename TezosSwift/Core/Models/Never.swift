//
//  Never.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/27/19.
//  Copyright © 2019 Ackee. All rights reserved.
//

import Foundation

extension Never: RPCCodable {
    public func encodeRPC<K>(in container: inout KeyedEncodingContainer<K>, forKey key: K) throws where K : CodingKey {
        fatalError()
    }
    
    public func encodeRPC<T>(in container: inout T) throws where T : UnkeyedEncodingContainer {
        fatalError()
    }
    
    public init(from decoder: Decoder) throws {
        fatalError()
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
}
