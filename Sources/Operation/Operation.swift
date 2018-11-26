import Foundation

/**
 * An abstract super class representing an operation to perform on the blockchain. Common parameters
 * across operations and default parameter values are provided by the abstract class's
 * implementation.
 */

public class Operation: Encodable {
	/** A Tezos balance representing 0. */
	public static let zeroTez = Tez(0)

	/** A Tezos balance that is the default used for gas and storage limits. */
	public static let defaultLimitTez = Tez(0.01)

//    [{"branch":"BMYXqQrjxXnpBF5HiyWaEPwozV1mbUAWmV32HhXVUnDZp8vMWvt","contents":[{"amount":"10000000","counter":"228798","destination":"KT1Agon3ARPS7U74UedWpR96j1CCbPCsSTsL","fee":"0000000","gas_limit":"0010000","kind":"transaction","source":"tz1ZfhME1B2kmagqEJ9P7PE8joM3TbVQ5r4v","storage_limit":"0010000"}],"protocol":"PsYLVpVvgbLhAhoqAkMFUo6gudkJ9weNXhUYCiLDzcUpFpkk8Wt","signature":"edsigu6bLbNGCZkdxuXBLnQKatGhDioWAcMiqHdgUxvrv2WbBpF9KaTUVhZzdPgfhgiUPFKUuRmkJjuVcd2VFw6nBChVzBEP4GU"}]
//    [{"signature":"edsigtnMcdQ8wzwazFmnu1umEVNARs8yjHQ3mQuoZQjn9X7SZPEqazy9JNrGdeBmQwXFbLgP6Rdrr8Ev57knoqEFw4JgCc4c7Ac","protocol":"PsYLVpVvgbLhAhoqAkMFUo6gudkJ9weNXhUYCiLDzcUpFpkk8Wt","branch":"BKwSpVy8SxFgqnP7bovjvBLSbuiiBU5C6y44nwu9GDWJAPUjtkz","contents":[{"amount":"1000000","source":"tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw","destination":"KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9","storage_limit":"0001000","gas_limit":"0001000","fee":"0000000","kind":"transaction","counter":"32183","parameters":{"int":"10"}}]}]
//    [{"branch":"BMYXqQrjxXnpBF5HiyWaEPwozV1mbUAWmV32HhXVUnDZp8vMWvt","contents":[{"amount":"10000000","counter":"228798","destination":"KT1Agon3ARPS7U74UedWpR96j1CCbPCsSTsL","fee":"0000000","gas_limit":"0010000","kind":"transaction","source":"tz1ZfhME1B2kmagqEJ9P7PE8joM3TbVQ5r4v","storage_limit":"0010000"}],"protocol":"PsYLVpVvgbLhAhoqAkMFUo6gudkJ9weNXhUYCiLDzcUpFpkk8Wt","signature":"edsigu6bLbNGCZkdxuXBLnQKatGhDioWAcMiqHdgUxvrv2WbBpF9KaTUVhZzdPgfhgiUPFKUuRmkJjuVcd2VFw6nBChVzBEP4GU"}]

	public let source: String
	public let kind: OperationKind
	public let fee: Tez
	public let gasLimit: Tez
	public let storageLimit: Tez
	public var requiresReveal: Bool {
		switch self.kind {
		case .delegation, .transaction, .origination:
			return true
		case .activateAccount, .reveal:
			return false
		}
	}
    public var counter: Int = 0

	public init(source: String,
		kind: OperationKind,
		fee: Tez = Operation.zeroTez,
		gasLimit: Tez = Operation.defaultLimitTez,
		storageLimit: Tez = Operation.defaultLimitTez) {
		self.source = source
		self.kind = kind
		self.fee = fee
		self.gasLimit = gasLimit
		self.storageLimit = storageLimit
	}

    private enum OperationKeys: String, CodingKey {
        case kind = "kind"
        case counter = "counter"
        case storageLimit = "storage_limit"
        case gasLimit = "gas_limit"
        case fee = "fee"
        case source = "source"
        case parameters = "parameters"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OperationKeys.self)
        try container.encode(kind.rawValue, forKey: .kind)
        try container.encode(String(counter), forKey: .counter)
        try container.encode(storageLimit, forKey: .storageLimit)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(fee, forKey: .fee)
        try container.encode(source, forKey: .source)
    }
}
