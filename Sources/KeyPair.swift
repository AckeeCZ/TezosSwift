import Foundation
import Sodium

/** Generic KeyPair protocol containing private and public keys. */
public protocol KeyPair {
  var publicKey: [UInt8] { get }
  var secretKey: [UInt8] { get }
}

/** Generic KeyPair struct. */
public struct DefaultKeyPair: KeyPair {
  public let publicKey: [UInt8]
  public let secretKey: [UInt8]
}

/** Extension on Sodium's Sign.KeyPair to work with TezosKit code. */
extension Sign.KeyPair: KeyPair {}