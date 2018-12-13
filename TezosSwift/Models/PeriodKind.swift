//
//  PeriodKind.swift
//  BigInt
//
//  Created by Marek Fořt on 12/13/18.
//

import Foundation

public enum PeriodKind: String, Decodable {
    case proposal = "proposal"
    case testingVote = "testing_vote"
    case testing = "testing"
    case promotionVote = "promotion_vote"
}
