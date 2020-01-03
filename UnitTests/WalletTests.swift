import XCTest
import TezosSwift
import TezosSwift
@testable import TezosSwift_Example

class WalletTests: XCTestCase {
	private let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
	private let passphrase = "TezosKitTest"

	// Expected outputs for a wallet without a passphrase.
	let expectedPublicKeyNoPassphrase = "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
	let expectedSecretKeyNoPassphrase = "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
	let expectedPublicKeyHashNoPassphrase = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"

	// Expected outputs for a wallet with a passphrase.
	let expectedPublicKeyPassphrase = "edpktnCgi3C7ZLyLrF4NAebDkgu5PZRRJ9BafxskVEj6U1GycyRird"
	let expectedSecretKeyPassphrase = "edskRjazzmroxmJagYDhCT1jXna8m9H2qvjtPAcrZYZ31og4ud1u2kkxYGv8e7CjmbW33QubzugueXqLFPMbM2eAj6j3AQHrCW"
	let expectedPublicKeyHashPassphrase = "tz1ZfhME1B2kmagqEJ9P7PE8joM3TbVQ5r4v"


	// Wallet generation with no parameters should never fail.
    func testGenerateWallet() {
		let wallet = Wallet()
		XCTAssertNotNil(wallet)
		XCTAssertNotNil(wallet?.mnemonic)

		let walletWithPassphrase = Wallet(passphrase: passphrase)
		XCTAssertNotNil(walletWithPassphrase)
		XCTAssertNotNil(walletWithPassphrase?.mnemonic)
	}

    func testGenerateWalletMnemonicNoPassphrase() {
		guard let wallet = Wallet(mnemonic: mnemonic) else {
			XCTFail()
			return
		}

		XCTAssertNotNil(wallet.mnemonic)
		XCTAssertEqual(wallet.mnemonic!, mnemonic)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyNoPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyNoPassphrase)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
	}

    func testGenerateWalletMnemonicEmptyPassphrase() {
		guard let wallet = Wallet(mnemonic: mnemonic, passphrase: "") else {
			XCTFail()
			return
		}

		// A wallet with an empty passphrase should be the same as a wallet with no passphrase.
		XCTAssertNotNil(wallet.mnemonic)
		XCTAssertEqual(wallet.mnemonic!, mnemonic)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyNoPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyNoPassphrase)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
	}

    func testGenerateWalletMnemonicWithPassphrase() {
		guard let wallet = Wallet(mnemonic: mnemonic, passphrase: passphrase) else {
			XCTFail()
			return
		}

		// A wallet with an empty passphrase should be the same as a wallet with no passphrase.
		XCTAssertNotNil(wallet.mnemonic)
		XCTAssertEqual(wallet.mnemonic!, mnemonic)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyPassphrase)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashPassphrase)
	}

    func testGenerateWalletFromSecretKey() {
		guard let wallet = Wallet(secretKey: expectedSecretKeyNoPassphrase) else {
			XCTFail()
			return
		}

		XCTAssertNil(wallet.mnemonic)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyNoPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyNoPassphrase)

	}

    func testGenerateWalletFromInvalidSecretKey() {
		let wallet = Wallet(secretKey: "thisIsNotAValidKey")
		XCTAssertNil(wallet)
	}
    
    func testEqualityFromSecretKeys() {
      // Test equality on wallets generated from a secret key.
      let secretKey1 =
        "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
      let secretKey2 =
        "edskRr4SG9qd4Hx9jZvdQ5dS2bCKxUnaEnXv9BrwSs2YxU8g8WpQ2CfXuiE96BWSsceaSi6HvSz4YnTKkwVqeWpUF288SzLXZ5"
      guard let wallet1 = Wallet(secretKey: secretKey1),
        let wallet2 = Wallet(secretKey: secretKey1),
        let wallet3 = Wallet(secretKey: secretKey2)
        else {
            XCTFail()
            return
      }
      // Wallets 1 and 2 were generated from the same secret key, wallet 3 was not.
      XCTAssertEqual(wallet1, wallet2)
      XCTAssertNotEqual(wallet1, wallet3)
    }
}
