import Foundation

/**
 * An enum representing all supported operation types. Raw values of the enum represent the string
 * the Tezos blockchain expects for the "kind" attribute when forging / pre-applying / injecting
 * operations.
 */
public enum OperationKind: String {
  // Implemented operations
  case transaction = "transaction"
  case reveal = "reveal"

  // Planned / Unimplemented
	case delegation = "delegation"
	case origination = "origination"
	case activateAccount = "activate_account"
}
