// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.0 ^0.8.0 ^0.8.20 ^0.8.8;

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Errors.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors_0 {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }
}

// lib/solidity-utils/src/contracts/access-control/interfaces/IWithGuardian.sol

interface IWithGuardian {
    /**
     * @dev Event emitted when guardian gets updated
     * @param oldGuardian address of previous guardian
     * @param newGuardian address of the new guardian
     */
    event GuardianUpdated(address oldGuardian, address newGuardian);

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OnlyGuardianInvalidCaller(address account);

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OnlyGuardianOrOwnerInvalidCaller(address account);

    /**
     * @dev get guardian address;
     */
    function guardian() external view returns (address);

    /**
     * @dev method to update the guardian
     * @param newGuardian the new guardian address
     */
    function updateGuardian(address newGuardian) external;
}

// lib/solidity-utils/src/contracts/utils/interfaces/IRescuableBase.sol

/**
 * @title IRescuableBase
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the RescuableBase contract
 */
interface IRescuableBase {
    error EthTransferFailed();
    /**
     * @notice emitted when erc20 tokens get rescued
     * @param caller address that triggers the rescue
     * @param token address of the rescued token
     * @param to address that will receive the rescued tokens
     * @param amount quantity of tokens rescued
     */

    event ERC20Rescued(address indexed caller, address indexed token, address indexed to, uint256 amount);

    /**
     * @notice emitted when native tokens get rescued
     * @param caller address that triggers the rescue
     * @param to address that will receive the rescued tokens
     * @param amount quantity of tokens rescued
     */
    event NativeTokensRescued(address indexed caller, address indexed to, uint256 amount);

    /**
     * @notice method that defined the maximum amount rescuable for any given asset.
     * @dev there's currently no way to limit the rescuable "native asset", as we assume erc20s as intended underlying.
     * @return the maximum amount of
     */
    function maxRescue(address erc20Token) external view returns (uint256);
}

// src/contracts/interfaces/IBaseReceiverPortal.sol

/**
 * @title IBaseReceiverPortal
 * @author BGD Labs
 * @notice interface defining the method that needs to be implemented by all receiving portals, as its the one that
 *            will be called when a received message gets confirmed
 */
interface IBaseReceiverPortal {
    /**
     * @notice method called by CrossChainController when a message has been confirmed
     * @param originSender address of the sender of the bridged message
     * @param originChainId id of the chain where the message originated
     * @param message bytes bridged containing the desired information
     */
    function receiveCrossChainMessage(address originSender, uint256 originChainId, bytes memory message) external;
}

// src/contracts/libs/EncodingUtils.sol

using EnvelopeUtils for Envelope global;
using TransactionUtils for Transaction global;

/**
 * @notice Object with the necessary information to define a unique envelope
 * @param nonce sequential (unique) numeric indicator of the Envelope creation
 * @param origin address that originated the bridging of a message
 * @param destination address where the message needs to be sent
 * @param originChainId id of the chain where the message originated
 * @param destinationChainId id of the chain where the message needs to be bridged
 * @param message bytes that needs to be bridged
 */
struct Envelope {
    uint256 nonce;
    address origin;
    address destination;
    uint256 originChainId;
    uint256 destinationChainId;
    bytes message;
}

/**
 * @notice Object containing the information of an envelope for internal usage
 * @param data bytes of the encoded envelope
 * @param id hash of the encoded envelope
 */
struct EncodedEnvelope {
    bytes data;
    bytes32 id;
}

/**
 * @title EnvelopeUtils library
 * @author BGD Labs
 * @notice Defines utility functions for Envelopes
 */
library EnvelopeUtils {
    /**
     * @notice method that encodes an Envelope and generates its id
     * @param envelope object with the routing information necessary to send a message to a destination chain
     * @return object containing the encoded envelope and the envelope id
     */
    function encode(Envelope memory envelope) internal pure returns (EncodedEnvelope memory) {
        EncodedEnvelope memory encodedEnvelope;
        encodedEnvelope.data = abi.encode(envelope);
        encodedEnvelope.id = getId(encodedEnvelope.data);
        return encodedEnvelope;
    }

    /**
     * @notice method to decode and encoded envelope to its raw parameters
     * @param envelope bytes with the encoded envelope data
     * @return object with the decoded envelope information
     */
    function decode(bytes memory envelope) internal pure returns (Envelope memory) {
        return abi.decode(envelope, (Envelope));
    }

    /**
     * @notice method to get an envelope's id
     * @param envelope object with the routing information necessary to send a message to a destination chain
     * @return hash id of the envelope
     */
    function getId(Envelope memory envelope) internal pure returns (bytes32) {
        EncodedEnvelope memory encodedEnvelope = encode(envelope);
        return encodedEnvelope.id;
    }

    /**
     * @notice method to get an envelope's id
     * @param envelope bytes with the encoded envelope data
     * @return hash id of the envelope
     */
    function getId(bytes memory envelope) internal pure returns (bytes32) {
        return keccak256(envelope);
    }
}

/**
 * @notice Object with the necessary information to send an envelope to a bridge
 * @param nonce sequential (unique) numeric indicator of the Transaction creation
 * @param encodedEnvelope bytes of an encoded envelope object
 */
struct Transaction {
    uint256 nonce;
    bytes encodedEnvelope;
}

/**
 * @notice Object containing the information of a transaction for internal usage
 * @param data bytes of the encoded transaction
 * @param id hash of the encoded transaction
 */
struct EncodedTransaction {
    bytes data;
    bytes32 id;
}

/**
 * @title TransactionUtils library
 * @author BGD Labs
 * @notice Defines utility functions for Transactions
 */
library TransactionUtils {
    /**
     * @notice method that encodes a Transaction and generates its id
     * @param transaction object with the information necessary to send an envelope to a bridge
     * @return object containing the encoded transaction and the transaction id
     */
    function encode(Transaction memory transaction) internal pure returns (EncodedTransaction memory) {
        EncodedTransaction memory encodedTransaction;
        encodedTransaction.data = abi.encode(transaction);
        encodedTransaction.id = getId(encodedTransaction.data);
        return encodedTransaction;
    }

    /**
     * @notice method that decodes an encoded transaction (bytes) into a Transaction object
     * @param transaction encoded transaction object
     * @return object containing the decoded Transaction object
     */
    function decode(bytes memory transaction) internal pure returns (Transaction memory) {
        return abi.decode(transaction, (Transaction));
    }

    /**
     * @notice method to get a transaction id
     * @param transaction object with the information necessary to send an envelope to a bridge
     * @return hash id of the transaction
     */
    function getId(Transaction memory transaction) internal pure returns (bytes32) {
        EncodedTransaction memory encodedTransaction = encode(transaction);
        return encodedTransaction.id;
    }

    /**
     * @notice method to get a transaction id
     * @param transaction encoded transaction object
     * @return hash id of the transaction
     */
    function getId(bytes memory transaction) internal pure returns (bytes32) {
        return keccak256(transaction);
    }

    /**
     * @notice method to get the envelope information from the transaction object
     * @param transaction object with the information necessary to send an envelope to a bridge
     * @return object with decoded information of the envelope in the transaction
     */
    function getEnvelope(Transaction memory transaction) internal pure returns (Envelope memory) {
        return EnvelopeUtils.decode(transaction.encodedEnvelope);
    }

    /**
     * @notice method to get the envelope id from the transaction object
     * @param transaction object with the information necessary to send an envelope to a bridge
     * @return hash id of the envelope on a transaction
     */
    function getEnvelopeId(Transaction memory transaction) internal pure returns (bytes32) {
        return EnvelopeUtils.getId(transaction.encodedEnvelope);
    }
}

// src/contracts/libs/Errors.sol

/**
 * @title Errors library
 * @author BGD Labs
 * @notice Defines the error messages emitted by the different contracts of the Aave CrossChain Infrastructure
 */
library Errors_1 {
    string public constant ETH_TRANSFER_FAILED = "1"; // failed to transfer eth to destination
    string public constant CALLER_IS_NOT_APPROVED_SENDER = "2"; // caller must be an approved message sender
    string public constant ENVELOPE_NOT_PREVIOUSLY_REGISTERED = "3"; // envelope can only be retried if it has been previously registered
    string public constant CURRENT_OR_DESTINATION_CHAIN_ADAPTER_NOT_SET = "4"; // can not enable bridge adapter if the current or destination chain adapter is 0 address
    string public constant CALLER_NOT_APPROVED_BRIDGE = "5"; // caller must be an approved bridge
    string public constant INVALID_VALIDITY_TIMESTAMP = "6"; // new validity timestamp is not correct (< last validity or in the future
    string public constant CALLER_NOT_CCIP_ROUTER = "7"; // caller must be bridge provider contract
    string public constant CCIP_ROUTER_CANT_BE_ADDRESS_0 = "8"; // CCIP bridge adapters needs a CCIP Router
    string public constant RECEIVER_NOT_SET = "9"; // receiver address on destination chain can not be 0
    string public constant DESTINATION_CHAIN_ID_NOT_SUPPORTED = "10"; // destination chain id must be supported by bridge provider
    string public constant NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES = "11"; // cross chain controller does not have enough funds to forward the message
    string public constant REMOTE_NOT_TRUSTED = "12"; // remote address has not been registered as a trusted origin
    string public constant CALLER_NOT_HL_MAILBOX = "13"; // caller must be the HyperLane Mailbox contract
    string public constant NO_BRIDGE_ADAPTERS_FOR_SPECIFIED_CHAIN = "14"; // no bridge adapters are configured for the specified destination chain
    string public constant ONLY_ONE_EMERGENCY_UPDATE_PER_CHAIN = "15"; // only one emergency update is allowed at the time
    string public constant INVALID_REQUIRED_CONFIRMATIONS = "16"; // required confirmations must be less or equal than allowed adapters or bigger or equal than 1
    string public constant DESTINATION_CHAIN_NOT_SAME_AS_CURRENT_CHAIN = "17"; // destination chain must be the same chain as the current chain where contract is deployed
    string public constant INVALID_BRIDGE_ADAPTER = "18"; // a bridge adapter address can not be the 0 address
    string public constant TRANSACTION_NOT_PREVIOUSLY_FORWARDED = "19"; // to retry sending a transaction, it needs to have been previously sent
    string public constant TRANSACTION_RETRY_FAILED = "20"; // transaction retry has failed (no bridge adapters where able to send)
    string public constant BRIDGE_ADAPTERS_SHOULD_BE_UNIQUE = "21"; // can not use the same bridge adapter twice
    string public constant ENVELOPE_NOT_CONFIRMED_OR_DELIVERED = "22"; // to deliver an envelope, this should have been previously confirmed
    string public constant INVALID_BASE_ADAPTER_CROSS_CHAIN_CONTROLLER = "23"; // crossChainController address can not be 0
    string public constant DELEGATE_CALL_FORBIDDEN = "24"; // calling this function during delegatecall is forbidden
    string public constant CALLER_NOT_LZ_ENDPOINT = "25"; // caller must be the LayerZero endpoint contract
    string public constant INVALID_LZ_ENDPOINT = "26"; // LayerZero endpoint can't be 0
    string public constant INVALID_TRUSTED_REMOTE = "27"; // trusted remote endpoint can't be 0
    string public constant INVALID_EMERGENCY_ORACLE = "28"; // emergency oracle can not be 0 because if not, system could not be rescued on emergency
    string public constant NOT_IN_EMERGENCY = "29"; // execution can only happen when in an emergency
    string public constant LINK_TOKEN_CANT_BE_ADDRESS_0 = "30"; // link token address should be set
    string public constant CCIP_MESSAGE_IS_INVALID = "31"; // ccip message is not an accepted message
    string public constant ADAPTER_PAYMENT_SETUP_FAILED = "32"; // adapter payment setup failed
    string public constant CHAIN_ID_MISMATCH = "33"; // the message delivered to/from wrong network
    string public constant CALLER_NOT_OVM = "34"; // the caller must be the optimism ovm contract
    string public constant CALLER_NOT_FX_TUNNEL = "35"; // the caller must be the fx tunnel contract
    string public constant INVALID_SENDER = "36"; // sender can not be address 0
    string public constant CALLER_NOT_GNOSIS_ARBITRARY_MESSAGE_BRIDGE = "37"; // the caller must be the Gnosis AMB contract
    string public constant ZERO_GNOSIS_ARBITRARY_MESSAGE_BRIDGE = "38"; // The passed Gnosis AMB contract is zero
    string public constant CALLER_NOT_ZK_EVM_BRIDGE = "39"; // the caller must be the zk evm bridge
    string public constant INVALID_HL_MAILBOX = "40"; // the Hyperlane mailbox address can not be 0
    string public constant WORMHOLE_RELAYER_CANT_BE_ADDRESS_0 = "41"; // Wormhole relayer can not be address 0
    string public constant CALLER_NOT_WORMHOLE_RELAYER = "42"; // caller must be the Wormhole relayer
    string public constant ZK_SYNC_BRIDGE_HUB_CANT_BE_ADDRESS_0 = "43"; // ZkSync Bridgehub can not be address 0
    string public constant CL_GAS_PRICE_ORACLE_CANT_BE_ADDRESS_0 = "44"; // ChainLink gas price oracle can not be address 0
    string public constant CALLER_NOT_LINEA_MESSAGE_SERVICE = "45"; // caller must be the Linea message service
    string public constant LINEA_MESSAGE_SERVICE_CANT_BE_ADDRESS_0 = "46"; // Linea message service can not be address 0
}

// src/contracts/libs/Utils.sol

library Utils {
    /**
     * @notice method to get a pseudo random number from previous block number, blockHash of the previous block number and an entropy value
     * @param entropy number assigned by method caller to give certain entropy to the pseudo random generation
     * @return a pseudo random number
     * @dev As this method does not offer real randomness, evaluate appropriately its usage.
     */
    function getPseudoRandom(uint256 entropy) internal view returns (uint256) {
        uint256 blockNumber = block.number - 1;
        return uint256(keccak256(abi.encodePacked(blockNumber, blockhash(blockNumber), entropy)));
    }

    /**
     * @notice method to generate an array of indexes with the specified length [0,1,2,...]
     * @param length number indicating the size of the array to generate
     * @return array of numbers with specified length
     */
    function generateIndexArray(uint256 length) internal pure returns (uint256[] memory) {
        uint256[] memory indexArray = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            indexArray[i] = i;
        }
        return indexArray;
    }

    /**
     * @notice method to shuffle an array of forwarder configurations
     * @param arrayToShuffle array that needs to be shuffled
     * @return shuffled array of forwarder configurations
     */
    function shuffleArray(uint256[] memory arrayToShuffle, uint256 optimalBandwidth)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 arrayLength = arrayToShuffle.length;
        for (uint256 i = 0; i < optimalBandwidth; i++) {
            uint256 j = getPseudoRandom(i) % arrayLength;
            uint256 arrayItem = arrayToShuffle[i];
            arrayToShuffle[i] = arrayToShuffle[j];
            arrayToShuffle[j] = arrayItem;
        }
        return arrayToShuffle;
    }
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors_0.InsufficientBalance(address(this).balance, amount);
        }

        (bool success,) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors_0.FailedCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors_0.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata)
        internal
        view
        returns (bytes memory)
    {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors_0.FailedCall();
        }
    }
}

// lib/solidity-utils/src/contracts/utils/interfaces/IRescuable.sol

/**
 * @title IRescuable
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the Rescuable contract
 */
interface IRescuable is IRescuableBase {
    error OnlyRescueGuardian();

    /**
     * @notice method called to rescue tokens sent erroneously to the contract. Only callable by owner
     * @param erc20Token address of the token to rescue
     * @param to address to send the tokens
     * @param amount of tokens to rescue
     */
    function emergencyTokenTransfer(address erc20Token, address to, uint256 amount) external;

    /**
     * @notice method called to rescue ether sent erroneously to the contract. Only callable by owner
     * @param to address to send the eth
     * @param amount of eth to rescue
     */
    function emergencyEtherTransfer(address to, uint256 amount) external;
}

// src/contracts/interfaces/ICrossChainForwarder.sol

/**
 * @title ICrossChainForwarder
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the CrossChainForwarder contract
 */
interface ICrossChainForwarder {
    /**
     * @notice Object containing the optimal bandwidth for communication with a receiver chain id
     * @param chainId id of the receiver chain
     * @param optimalBandwidth optimal number of bridge adapters to use to send a message to receiver chain
     */
    struct OptimalBandwidthByChain {
        uint256 chainId;
        uint256 optimalBandwidth;
    }

    /**
     * @notice object storing the connected pair of bridge adapters, on current and destination chain
     * @param destinationBridgeAdapter address of the bridge adapter on the destination chain
     * @param currentChainBridgeAdapter address of the bridge adapter deployed on current network
     */
    struct ChainIdBridgeConfig {
        address destinationBridgeAdapter;
        address currentChainBridgeAdapter;
    }

    /**
     * @notice object with the necessary information to remove bridge adapters
     * @param bridgeAdapter address of the bridge adapter to remove
     * @param chainIds array of chain ids where the bridge adapter connects
     */
    struct BridgeAdapterToDisable {
        address bridgeAdapter;
        uint256[] chainIds;
    }

    /**
     * @notice object storing the pair bridgeAdapter (current deployed chain) destination chain bridge adapter configuration
     * @param currentChainBridgeAdapter address of the bridge adapter deployed on current chain
     * @param destinationBridgeAdapter address of the bridge adapter on the destination chain
     * @param destinationChainId id of the destination chain using our own nomenclature
     */
    struct ForwarderBridgeAdapterConfigInput {
        address currentChainBridgeAdapter;
        address destinationBridgeAdapter;
        uint256 destinationChainId;
    }

    /**
     * @notice emitted when a transaction is successfully forwarded through a bridge adapter
     * @param envelopeId internal id of the envelope
     * @param envelope the Envelope type data
     */
    event EnvelopeRegistered(bytes32 indexed envelopeId, Envelope envelope);

    /**
     * @notice emitted when a transaction forwarding is attempted through a bridge adapter
     * @param transactionId id of the forwarded transaction
     * @param envelopeId internal id of the envelope
     * @param encodedTransaction object intended to be bridged
     * @param destinationChainId id of the destination chain in our notation
     * @param bridgeAdapter address of the bridge adapter that failed (deployed on current network)
     * @param destinationBridgeAdapter address of the connected bridge adapter on destination chain
     * @param adapterSuccessful adapter was able to forward the message
     * @param returnData bytes with error information
     */
    event TransactionForwardingAttempted(
        bytes32 transactionId,
        bytes32 indexed envelopeId,
        bytes encodedTransaction,
        uint256 destinationChainId,
        address indexed bridgeAdapter,
        address destinationBridgeAdapter,
        bool indexed adapterSuccessful,
        bytes returnData
    );

    /**
     * @notice emitted when a bridge adapter has been added to the allowed list
     * @param destinationChainId id of the destination chain in our notation
     * @param bridgeAdapter address of the bridge adapter added (deployed on current network)
     * @param destinationBridgeAdapter address of the connected bridge adapter on destination chain
     * @param allowed boolean indicating if the bridge adapter is allowed or disallowed
     */
    event BridgeAdapterUpdated(
        uint256 indexed destinationChainId,
        address indexed bridgeAdapter,
        address destinationBridgeAdapter,
        bool indexed allowed
    );
    /**
     * @notice emitted when the optimal bandwidth is updated for a specified receiver chain
     * @param chainId id of the receiver chain that gets the new optimal bandwidth
     * @param optimalBandwidth optimal number of adapters to use for sending a message to a receiver chain
     */
    event OptimalBandwidthUpdated(uint256 indexed chainId, uint256 optimalBandwidth);

    /**
     * @notice emitted when a sender has been updated
     * @param sender address of the updated sender
     * @param isApproved boolean that indicates if the sender has been approved or removed
     */
    event SenderUpdated(address indexed sender, bool indexed isApproved);

    /**
     * @notice method to get the current valid envelope nonce
     * @return the current valid envelope nonce
     */
    function getCurrentEnvelopeNonce() external view returns (uint256);

    /**
     * @notice method to get the current valid transaction nonce
     * @return the current valid transaction nonce
     */
    function getCurrentTransactionNonce() external view returns (uint256);

    /**
     * @notice method to check if a envelope has been previously forwarded.
     * @param envelope the Envelope type data
     * @return boolean indicating if the envelope has been registered
     */
    function isEnvelopeRegistered(Envelope memory envelope) external view returns (bool);

    /**
     * @notice method to check if a envelope has been previously forwarded.
     * @param envelopeId the hashed id of the envelope
     * @return boolean indicating if the envelope has been registered
     */
    function isEnvelopeRegistered(bytes32 envelopeId) external view returns (bool);

    /**
     * @notice method to get if a transaction has been forwarded
     * @param transaction the Transaction type data
     * @return flag indicating if a transaction has been forwarded
     */
    function isTransactionForwarded(Transaction memory transaction) external view returns (bool);

    /**
     * @notice method to get if a transaction has been forwarded
     * @param transactionId hashed id of the transaction
     * @return flag indicating if a transaction has been forwarded
     */
    function isTransactionForwarded(bytes32 transactionId) external view returns (bool);

    /**
     * @notice method called to initiate message forwarding to other networks.
     * @param destinationChainId id of the destination chain where the message needs to be bridged
     * @param destination address where the message is intended for
     * @param gasLimit gas cost on receiving side of the message
     * @param message bytes that need to be bridged
     * @return internal id of the envelope and transaction
     */
    function forwardMessage(uint256 destinationChainId, address destination, uint256 gasLimit, bytes memory message)
        external
        returns (bytes32, bytes32);

    /**
     * @notice method called to re forward a previously sent envelope.
     * @param envelope the Envelope type data
     * @param gasLimit gas cost on receiving side of the message
     * @return the transaction id that has the retried envelope
     * @dev This method will send an existing Envelope using a new Transaction.
     * @dev This method should be used when the intention is to send the Envelope as if it was a new message. This way on
     *       the Receiver side it will start from 0 to count for the required confirmations. (usual use case would be for
     *       when an envelope has been invalidated on Receiver side, and needs to be retried as a new message)
     */
    function retryEnvelope(Envelope memory envelope, uint256 gasLimit) external returns (bytes32);

    /**
     * @notice method to retry forwarding an already forwarded transaction
     * @param encodedTransaction the encoded Transaction data
     * @param gasLimit limit of gas to spend on forwarding per bridge
     * @param bridgeAdaptersToRetry list of bridge adapters to be used for the transaction forwarding retry
     * @dev This method will send an existing Transaction with its Envelope to the specified adapters.
     * @dev Should be used when some of the bridges on the initial forwarding did not work (out of gas),
     *       and we want the Transaction with Envelope to still account for the required confirmations on the Receiver side
     */
    function retryTransaction(bytes memory encodedTransaction, uint256 gasLimit, address[] memory bridgeAdaptersToRetry)
        external;

    /**
     * @notice method to enable bridge adapters
     * @param bridgeAdapters array of new bridge adapter configurations
     */
    function enableBridgeAdapters(ForwarderBridgeAdapterConfigInput[] memory bridgeAdapters) external;

    /**
     * @notice method to disable bridge adapters
     * @param bridgeAdapters array of bridge adapter addresses to disable
     */
    function disableBridgeAdapters(BridgeAdapterToDisable[] memory bridgeAdapters) external;

    /**
     * @notice method to remove sender addresses
     * @param senders list of addresses to remove
     */
    function removeSenders(address[] memory senders) external;

    /**
     * @notice method to approve new sender addresses
     * @param senders list of addresses to approve
     */
    function approveSenders(address[] memory senders) external;

    /**
     * @notice method to get all the forwarder bridge adapters of a chain
     * @param chainId id of the chain we want to get the adapters from
     * @return an array of chain configurations where the bridge adapter can communicate
     */
    function getForwarderBridgeAdaptersByChain(uint256 chainId) external view returns (ChainIdBridgeConfig[] memory);

    /**
     * @notice method to get if a sender is approved
     * @param sender address that we want to check if approved
     * @return boolean indicating if the address has been approved as sender
     */
    function isSenderApproved(address sender) external view returns (bool);

    /**
     * @notice method to update the optimal bandwidth for communication with a receiver chain
     * @param optimalBandwidthByChain array of objects containing the optimal bandwidth for a specified
     *         receiver chain id
     */
    function updateOptimalBandwidthByChain(OptimalBandwidthByChain[] memory optimalBandwidthByChain) external;

    /**
     * @notice method to get the optimal bandwidth for communication with the receiver chain
     * @param chainId id of the receiver chain to get the optimal bandwidth from
     * @return optimal bandwidth of the receiver chain
     */
    function getOptimalBandwidthByChain(uint256 chainId) external view returns (uint256);
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation = 0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner) internal onlyInitializing {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// src/contracts/interfaces/ICrossChainReceiver.sol

/**
 * @title ICrossChainReceiver
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the CrossChainReceiver contract
 */
interface ICrossChainReceiver {
    /**
     * @notice object with information to set new required confirmations
     * @param chainId id of the origin chain
     * @param requiredConfirmations required confirmations to set a message as confirmed
     */
    struct ConfirmationInput {
        uint256 chainId;
        uint8 requiredConfirmations;
    }

    /**
     * @notice object with information to set new validity timestamp
     * @param chainId id of the origin chain
     * @param validityTimestamp new timestamp in seconds to set as validity point
     */
    struct ValidityTimestampInput {
        uint256 chainId;
        uint120 validityTimestamp;
    }

    /**
     * @notice object with necessary information to configure bridge adapters
     * @param bridgeAdapter address of the bridge adapter to configure
     * @param chainIds array of ids of the chains the adapter receives messages from
     */
    struct ReceiverBridgeAdapterConfigInput {
        address bridgeAdapter;
        uint256[] chainIds;
    }

    /**
     * @notice object containing the receiver configuration
     * @param requiredConfirmation number of bridges that are needed to make a bridged message valid from origin chain
     * @param validityTimestamp all messages originated but not finally confirmed before this timestamp per origin chain, are invalid
     */
    struct ReceiverConfiguration {
        uint8 requiredConfirmation;
        uint120 validityTimestamp;
    }

    /**
     * @notice object with full information of the receiver configuration for a chain
     * @param configuration object containing the specifications of the receiver for a chain
     * @param allowedBridgeAdapters stores if a bridge adapter is allowed for a chain
     */
    struct ReceiverConfigurationFull {
        ReceiverConfiguration configuration;
        EnumerableSet.AddressSet allowedBridgeAdapters;
    }

    /**
     * @notice object that stores the internal information of the transaction
     * @param confirmations number of times that this transaction has been bridged
     * @param firstBridgedAt timestamp in seconds indicating the first time a transaction was received
     */
    struct TransactionStateWithoutAdapters {
        uint8 confirmations;
        uint120 firstBridgedAt;
    }
    /**
     * @notice object that stores the internal information of the transaction with bridge adapters state
     * @param confirmations number of times that this transactions has been bridged
     * @param firstBridgedAt timestamp in seconds indicating the first time a transaction was received
     * @param bridgedByAdapter list of bridge adapters that have bridged the message
     */

    struct TransactionState {
        uint8 confirmations;
        uint120 firstBridgedAt;
        mapping(address => bool) bridgedByAdapter;
    }

    /**
     * @notice object with the current state of an envelope
     * @param confirmed boolean indicating if the bridged message has been confirmed by the infrastructure
     * @param delivered boolean indicating if the bridged message has been delivered to the destination
     */
    enum EnvelopeState {
        None,
        Confirmed,
        Delivered
    }

    /**
     * @notice emitted when a transaction has been received successfully
     * @param transactionId id of the transaction
     * @param envelopeId id of the envelope
     * @param originChainId id of the chain where the envelope originated
     * @param transaction the Transaction type data
     * @param bridgeAdapter address of the bridge adapter who received the message (deployed on current network)
     * @param confirmations number of current confirmations for this message
     */
    event TransactionReceived(
        bytes32 transactionId,
        bytes32 indexed envelopeId,
        uint256 indexed originChainId,
        Transaction transaction,
        address indexed bridgeAdapter,
        uint8 confirmations
    );

    /**
     * @notice emitted when an envelope has been delivery attempted
     * @param envelopeId id of the envelope
     * @param envelope the Envelope type data
     * @param isDelivered flag indicating if the message has been delivered successfully
     */
    event EnvelopeDeliveryAttempted(bytes32 envelopeId, Envelope envelope, bool isDelivered);

    /**
     * @notice emitted when a bridge adapter gets updated (allowed or disallowed)
     * @param bridgeAdapter address of the updated bridge adapter
     * @param allowed boolean indicating if the bridge adapter has been allowed or disallowed
     * @param chainId id of the chain updated
     */
    event ReceiverBridgeAdaptersUpdated(address indexed bridgeAdapter, bool indexed allowed, uint256 indexed chainId);

    /**
     * @notice emitted when number of confirmations needed to validate a message changes
     * @param newConfirmations number of new confirmations needed for a message to be valid
     * @param chainId id of the chain updated
     */
    event ConfirmationsUpdated(uint8 newConfirmations, uint256 indexed chainId);

    /**
     * @notice emitted when a new timestamp for invalidations gets set
     * @param invalidTimestamp timestamp to invalidate previous messages
     * @param chainId id of the chain updated
     */
    event NewInvalidation(uint256 invalidTimestamp, uint256 indexed chainId);

    /**
     * @notice method to get the current allowed receiver bridge adapters for a chain
     * @param chainId id of the chain to get the allowed bridge adapter list
     * @return the list of allowed bridge adapters
     */
    function getReceiverBridgeAdaptersByChain(uint256 chainId) external view returns (address[] memory);

    /**
     * @notice method to get the current supported chains (at least one allowed bridge adapter)
     * @return list of supported chains
     */
    function getSupportedChains() external view returns (uint256[] memory);

    /**
     * @notice method to get the current configuration of a chain
     * @param chainId id of the chain to get the configuration from
     * @return the specified chain configuration object
     */
    function getConfigurationByChain(uint256 chainId) external view returns (ReceiverConfiguration memory);

    /**
     * @notice method to get if a bridge adapter is allowed
     * @param bridgeAdapter address of the bridge adapter to check
     * @param chainId id of the chain to check
     * @return boolean indicating if bridge adapter is allowed
     */
    function isReceiverBridgeAdapterAllowed(address bridgeAdapter, uint256 chainId) external view returns (bool);

    /**
     * @notice  method to get the current state of a transaction
     * @param transactionId the id of transaction
     * @return number of confirmations of internal message identified by the transactionId and the updated timestamp
     */
    function getTransactionState(bytes32 transactionId)
        external
        view
        returns (TransactionStateWithoutAdapters memory);

    /**
     * @notice  method to get the internal transaction information
     * @param transaction Transaction type data
     * @return number of confirmations of internal message identified by internalId and the updated timestamp
     */
    function getTransactionState(Transaction memory transaction)
        external
        view
        returns (TransactionStateWithoutAdapters memory);

    /**
     * @notice method to get the internal state of an envelope
     * @param envelope the Envelope type data
     * @return the envelope current state, containing if it has been confirmed and delivered
     */
    function getEnvelopeState(Envelope memory envelope) external view returns (EnvelopeState);

    /**
     * @notice method to get the internal state of an envelope
     * @param envelopeId id of the envelope
     * @return the envelope current state, containing if it has been confirmed and delivered
     */
    function getEnvelopeState(bytes32 envelopeId) external view returns (EnvelopeState);

    /**
     * @notice method to get if transaction has been received by bridge adapter
     * @param transactionId id of the transaction as stored internally
     * @param bridgeAdapter address of the bridge adapter to check if it has bridged the message
     * @return boolean indicating if the message has been received
     */
    function isTransactionReceivedByAdapter(bytes32 transactionId, address bridgeAdapter)
        external
        view
        returns (bool);

    /**
     * @notice method to set a new timestamp from where the messages will be valid.
     * @param newValidityTimestamp array of objects containing the chain and timestamp where all the previous unconfirmed
     *         messages must be invalidated.
     */
    function updateMessagesValidityTimestamp(ValidityTimestampInput[] memory newValidityTimestamp) external;

    /**
     * @notice method to update the number of confirmations necessary for the messages to be accepted as valid
     * @param newConfirmations array of objects with the chainId and the new number of needed confirmations
     */
    function updateConfirmations(ConfirmationInput[] memory newConfirmations) external;

    /**
     * @notice method that receives a bridged transaction and tries to deliver the contents to destination if possible
     * @param encodedTransaction bytes containing the bridged information
     * @param originChainId id of the chain where the transaction originated
     */
    function receiveCrossChainMessage(bytes memory encodedTransaction, uint256 originChainId) external;

    /**
     * @notice method to deliver an envelope to its destination
     * @param envelope the Envelope typed data
     * @dev to deliver an envelope, it needs to have been previously confirmed and not delivered
     */
    function deliverEnvelope(Envelope memory envelope) external;

    /**
     * @notice method to add bridge adapters to the allowed list
     * @param bridgeAdaptersInput array of objects with the new bridge adapters and supported chains
     */
    function allowReceiverBridgeAdapters(ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersInput) external;

    /**
     * @notice method to remove bridge adapters from the allowed list
     * @param bridgeAdaptersInput array of objects with the bridge adapters and supported chains to disallow
     */
    function disallowReceiverBridgeAdapters(ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersInput) external;
}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data)
        external
        returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// lib/solidity-utils/src/contracts/access-control/UpgradeableOwnableWithGuardian.sol

/**
 * Forked version of https://github.com/bgd-labs/solidity-utils/blob/main/src/contracts/access-control/OwnableWithGuardian.sol
 * Relying on UpgradableOwnable & moving the storage to 7201
 */
abstract contract UpgradeableOwnableWithGuardian is OwnableUpgradeable, IWithGuardian {
    /// @custom:storage-location erc7201:aave.storage.OwnableWithGuardian
    struct OwnableWithGuardian {
        address _guardian;
    }

    // keccak256(abi.encode(uint256(keccak256("aave.storage.OwnableWithGuardian")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableWithGuardianStorageLocation =
        0xdc8016945fab92f4608d8f23802ef36d865b35bd839402e24dec05cd76049e00;

    function _getOwnableWithGuardianStorage() private pure returns (OwnableWithGuardian storage $) {
        assembly {
            $.slot := OwnableWithGuardianStorageLocation
        }
    }

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner & guardian.
     * @param initialOwner The address of the initial owner
     * @param initialGuardian The address of the initial guardian
     */
    function __Ownable_With_Guardian_init(address initialOwner, address initialGuardian) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
        __Ownable_With_Guardian_init_unchained(initialGuardian);
    }

    function __Ownable_With_Guardian_init_unchained(address initialGuardian) internal onlyInitializing {
        _updateGuardian(initialGuardian);
    }

    modifier onlyGuardian() {
        _checkGuardian();
        _;
    }

    modifier onlyOwnerOrGuardian() {
        _checkOwnerOrGuardian();
        _;
    }

    function guardian() public view override returns (address) {
        OwnableWithGuardian storage $ = _getOwnableWithGuardianStorage();
        return $._guardian;
    }

    /// @inheritdoc IWithGuardian
    function updateGuardian(address newGuardian) external override onlyOwnerOrGuardian {
        _updateGuardian(newGuardian);
    }

    /**
     * @dev method to update the guardian
     * @param newGuardian the new guardian address
     */
    function _updateGuardian(address newGuardian) internal {
        OwnableWithGuardian storage $ = _getOwnableWithGuardianStorage();
        address oldGuardian = $._guardian;
        $._guardian = newGuardian;
        emit GuardianUpdated(oldGuardian, newGuardian);
    }

    function _checkGuardian() internal view {
        if (guardian() != _msgSender()) revert OnlyGuardianInvalidCaller(_msgSender());
    }

    function _checkOwnerOrGuardian() internal view {
        if (_msgSender() != owner() && _msgSender() != guardian()) {
            revert OnlyGuardianOrOwnerInvalidCaller(_msgSender());
        }
    }
}

// src/contracts/interfaces/IBaseCrossChainController.sol

/**
 * @title IBaseCrossChainController
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the CrossChainController contract
 */
interface IBaseCrossChainController is IRescuable, ICrossChainForwarder, ICrossChainReceiver {}

// lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(IERC1363 token, address from, address to, uint256 value, bytes memory data)
        internal
    {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// src/contracts/adapters/IBaseAdapter.sol

/**
 * @title IBaseAdapter
 * @author BGD Labs
 * @notice interface containing the event and method used in all bridge adapters
 */
interface IBaseAdapter {
    /**
     * @notice emitted when a trusted remote is set
     * @param originChainId id of the chain where the trusted remote is from
     * @param originForwarder address of the contract that will send the messages
     */
    event SetTrustedRemote(uint256 originChainId, address originForwarder);

    /**
     * @notice pair of origin address and origin chain
     * @param originForwarder address of the contract that will send the messages
     * @param originChainId id of the chain where the trusted remote is from
     */
    struct TrustedRemotesConfig {
        address originForwarder;
        uint256 originChainId;
    }

    /**
     * @notice method that will bridge the payload to the chain specified
     * @param receiver address of the receiver contract on destination chain
     * @param executionGasLimit amount of the gas limit in wei to use for delivering the message on destination network.
     *         Each adapter will manage this as needed.
     * @param destinationChainId id of the destination chain in the bridge notation
     * @param message to send to the specified chain
     * @return the third-party bridge entrypoint, the third-party bridge message id
     */
    function forwardMessage(
        address receiver,
        uint256 executionGasLimit,
        uint256 destinationChainId,
        bytes calldata message
    ) external returns (address, uint256);

    /**
     * @notice method to get the address of the linked cross chain controller
     * @return address of CrossChainController
     */
    function CROSS_CHAIN_CONTROLLER() external returns (IBaseCrossChainController);

    /**
     * @notice method to get the name of the adapter contract
     * @return name of the adapter contract
     */
    function adapterName() external view returns (string memory);

    /**
     * @notice method to get the base gas limit used by the bridge adapter
     */
    function BASE_GAS_LIMIT() external returns (uint256);

    /**
     * @notice method used to setup payment, ie grant approvals over tokens used to pay for tx fees
     */
    function setupPayments() external;

    /**
     * @notice method to get the trusted remote address from a specified chain id
     * @param chainId id of the chain from where to get the trusted remote
     * @return address of the trusted remote
     */
    function getTrustedRemoteByChainId(uint256 chainId) external view returns (address);

    /**
     * @notice method to get infrastructure chain id from bridge native chain id
     * @param bridgeChainId bridge native chain id
     */
    function nativeToInfraChainId(uint256 bridgeChainId) external returns (uint256);

    /**
     * @notice method to get bridge native chain id from native bridge chain id
     * @param infraChainId infrastructure chain id
     */
    function infraToNativeChainId(uint256 infraChainId) external returns (uint256);
}

// src/contracts/interfaces/ICrossChainController.sol

/**
 * @title ICrossChainController
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the ICrossChainControllerMainnet contract
 */
interface ICrossChainController is IBaseCrossChainController {
    /**
     * @notice method called to initialize the proxy
     * @param owner address of the owner of the cross chain controller
     * @param guardian address of the guardian of the cross chain controller
     * @param initialRequiredConfirmations number of confirmations the messages need to be accepted as valid
     * @param receiverBridgeAdaptersToAllow array of addresses of the bridge adapters that can receive messages
     * @param forwarderBridgeAdaptersToEnable array specifying for every bridgeAdapter, the destinations it can have
     * @param sendersToApprove array of addresses to allow as forwarders
     * @param optimalBandwidthByChain array of optimal numbers of bridge adapters to use to send a message to receiver chain
     */
    function initialize(
        address owner,
        address guardian,
        ConfirmationInput[] memory initialRequiredConfirmations,
        ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
        ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
        address[] memory sendersToApprove,
        OptimalBandwidthByChain[] memory optimalBandwidthByChain
    ) external;
}

// lib/solidity-utils/src/contracts/utils/RescuableBase.sol

abstract contract RescuableBase is IRescuableBase {
    using SafeERC20 for IERC20;

    /// @inheritdoc IRescuableBase
    function maxRescue(address erc20Token) public view virtual returns (uint256);

    function _emergencyTokenTransfer(address erc20Token, address to, uint256 amount) internal {
        uint256 max = maxRescue(erc20Token);
        amount = max > amount ? amount : max;
        IERC20(erc20Token).safeTransfer(to, amount);

        emit ERC20Rescued(msg.sender, erc20Token, to, amount);
    }

    function _emergencyEtherTransfer(address to, uint256 amount) internal {
        (bool success,) = to.call{value: amount}(new bytes(0));
        if (!success) {
            revert EthTransferFailed();
        }

        emit NativeTokensRescued(msg.sender, to, amount);
    }
}

// src/contracts/CrossChainReceiver.sol

/**
 * @title CrossChainReceiver
 * @author BGD Labs
 * @notice this contract contains the methods to get bridged messages and route them to their respective recipients.
 * @dev to route a message, this one needs to be bridged correctly n number of confirmations.
 * @dev if at some point, it is detected that some bridge has been hacked, there is a possibility to invalidate
 *      messages by calling updateMessagesValidityTimestamp
 */
contract CrossChainReceiver is UpgradeableOwnableWithGuardian, ICrossChainReceiver {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // chainId => configuration
    mapping(uint256 => ReceiverConfigurationFull) internal _configurationsByChain;

    // stores hash(Transaction) => bridged transaction information and state
    mapping(bytes32 => TransactionState) internal _transactionsState;

    // stores hash(Envelope) => received envelope state
    mapping(bytes32 => EnvelopeState) internal _envelopesState;

    // stores the currently supported chains (chains that have at least 1 bridge adapter)
    EnumerableSet.UintSet internal _supportedChains;

    // storage gap allocation to be used for later updates. This way storage can be added on parent contract without
    // overwriting storage on child
    uint256[50] private __RECEIVER_GAP;

    // checks if caller is one of the approved bridge adapters
    modifier onlyApprovedBridges(uint256 chainId) {
        require(isReceiverBridgeAdapterAllowed(msg.sender, chainId), Errors_1.CALLER_NOT_APPROVED_BRIDGE);
        _;
    }

    /**
     * @param initialRequiredConfirmations number of confirmations the messages need to be accepted as valid
     * @param bridgeAdaptersToAllow array of objects containing the chain and address of the bridge adapters that
     *         can receive messages
     */
    constructor(
        ConfirmationInput[] memory initialRequiredConfirmations,
        ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersToAllow
    ) {
        _configureReceiverBasics(
            bridgeAdaptersToAllow, new ReceiverBridgeAdapterConfigInput[](0), initialRequiredConfirmations
        );
    }

    /// @inheritdoc ICrossChainReceiver
    function getReceiverBridgeAdaptersByChain(uint256 chainId) public view returns (address[] memory) {
        return _configurationsByChain[chainId].allowedBridgeAdapters.values();
    }

    /// @inheritdoc ICrossChainReceiver
    function getSupportedChains() external view returns (uint256[] memory) {
        return _supportedChains.values();
    }

    /// @inheritdoc ICrossChainReceiver
    function getConfigurationByChain(uint256 chainId) external view returns (ReceiverConfiguration memory) {
        return _configurationsByChain[chainId].configuration;
    }

    /// @inheritdoc ICrossChainReceiver
    function isReceiverBridgeAdapterAllowed(address bridgeAdapter, uint256 chainId) public view returns (bool) {
        return _configurationsByChain[chainId].allowedBridgeAdapters.contains(bridgeAdapter);
    }

    /// @inheritdoc ICrossChainReceiver
    function getTransactionState(bytes32 transactionId) public view returns (TransactionStateWithoutAdapters memory) {
        return TransactionStateWithoutAdapters({
            confirmations: _transactionsState[transactionId].confirmations,
            firstBridgedAt: _transactionsState[transactionId].firstBridgedAt
        });
    }

    /// @inheritdoc ICrossChainReceiver
    function getTransactionState(Transaction memory transaction)
        external
        view
        returns (TransactionStateWithoutAdapters memory)
    {
        return getTransactionState(transaction.getId());
    }

    /// @inheritdoc ICrossChainReceiver
    function getEnvelopeState(Envelope memory envelope) external view returns (EnvelopeState) {
        return getEnvelopeState(envelope.getId());
    }

    /// @inheritdoc ICrossChainReceiver
    function getEnvelopeState(bytes32 envelopeId) public view returns (EnvelopeState) {
        return _envelopesState[envelopeId];
    }

    /// @inheritdoc ICrossChainReceiver
    function isTransactionReceivedByAdapter(bytes32 transactionId, address bridgeAdapter)
        external
        view
        returns (bool)
    {
        return _transactionsState[transactionId].bridgedByAdapter[bridgeAdapter];
    }

    /// @inheritdoc ICrossChainReceiver
    function updateConfirmations(ConfirmationInput[] memory newConfirmations) external onlyOwner {
        _updateConfirmations(newConfirmations);
    }

    /// @inheritdoc ICrossChainReceiver
    function updateMessagesValidityTimestamp(ValidityTimestampInput[] memory newValidityTimestamp) external onlyOwner {
        _updateMessagesValidityTimestamp(newValidityTimestamp);
    }

    /// @inheritdoc ICrossChainReceiver
    function allowReceiverBridgeAdapters(ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersInput)
        external
        onlyOwner
    {
        _updateReceiverBridgeAdapters(bridgeAdaptersInput, true);
    }

    /// @inheritdoc ICrossChainReceiver
    function disallowReceiverBridgeAdapters(ReceiverBridgeAdapterConfigInput[] memory bridgeAdapters)
        external
        onlyOwner
    {
        _updateReceiverBridgeAdapters(bridgeAdapters, false);
    }

    /// @inheritdoc ICrossChainReceiver
    function receiveCrossChainMessage(bytes memory encodedTransaction, uint256 originChainId)
        external
        onlyApprovedBridges(originChainId)
    {
        Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
        Envelope memory envelope = transaction.getEnvelope();
        require(
            envelope.originChainId == originChainId && envelope.destinationChainId == block.chainid,
            Errors_1.CHAIN_ID_MISMATCH
        );
        bytes32 envelopeId = transaction.getEnvelopeId();

        bytes32 transactionId = TransactionUtils.getId(encodedTransaction);

        TransactionState storage internalTransaction = _transactionsState[transactionId];
        ReceiverConfiguration memory configuration = _configurationsByChain[originChainId].configuration;

        // If bridged at is > invalidation, it means that the first time transaction was received after last invalidation and
        // can be processed.
        // 0 here means that it’s received for a first time, so invalidation does not matter for this message.
        // Also checks that bridge adapter didn’t bridge this transaction already.
        // Dont let messages pass if required confirmations are 0. Meaning that they have not been configured
        uint120 transactionFirstBridgedAt = internalTransaction.firstBridgedAt;
        if (
            transactionFirstBridgedAt == 0
                || (
                    !internalTransaction.bridgedByAdapter[msg.sender]
                        && transactionFirstBridgedAt > configuration.validityTimestamp
                )
        ) {
            if (transactionFirstBridgedAt == 0) {
                internalTransaction.firstBridgedAt = uint120(block.timestamp);
            }

            uint8 newConfirmations = ++internalTransaction.confirmations;
            internalTransaction.bridgedByAdapter[msg.sender] = true;

            emit TransactionReceived(
                transactionId, envelopeId, originChainId, transaction, msg.sender, newConfirmations
            );
            // Checks that the message was not confirmed and/or delivered before, so it will not try to deliver again when message arrives
            // from additional bridges after reaching required number of confirmations
            if (_envelopesState[envelopeId] != EnvelopeState.None) {
                return;
            }

            // >= is used for the case when confirmations gets lowered before message reached the old _requiredConfirmations
            // but on receiving new messages it surpasses the current _requiredConfirmations. So it doesn't get stuck (if using ==)
            if (configuration.requiredConfirmation > 0 && newConfirmations >= configuration.requiredConfirmation) {
                _envelopesState[envelopeId] = EnvelopeState.Delivered;
                try IBaseReceiverPortal(envelope.destination).receiveCrossChainMessage(
                    envelope.origin, envelope.originChainId, envelope.message
                ) {
                    emit EnvelopeDeliveryAttempted(envelopeId, envelope, true);
                } catch (bytes memory) {
                    _envelopesState[envelopeId] = EnvelopeState.Confirmed;
                    emit EnvelopeDeliveryAttempted(envelopeId, envelope, false);
                }
            }
        }
    }

    /// @inheritdoc ICrossChainReceiver
    function deliverEnvelope(Envelope memory envelope) external {
        bytes32 envelopeId = envelope.getId();
        require(_envelopesState[envelopeId] == EnvelopeState.Confirmed, Errors_1.ENVELOPE_NOT_CONFIRMED_OR_DELIVERED);

        _envelopesState[envelopeId] = EnvelopeState.Delivered;
        IBaseReceiverPortal(envelope.destination).receiveCrossChainMessage(
            envelope.origin, envelope.originChainId, envelope.message
        );
        emit EnvelopeDeliveryAttempted(envelopeId, envelope, true);
    }

    /**
     * @notice method to set a new timestamp from where the messages will be valid.
     * @param newValidityTimestampsInput array of objects containing the chain and timestamp where all the previous unconfirmed
     *         messages must be invalidated.
     */
    function _updateMessagesValidityTimestamp(ValidityTimestampInput[] memory newValidityTimestampsInput) internal {
        for (uint256 i; i < newValidityTimestampsInput.length; i++) {
            ValidityTimestampInput memory input = newValidityTimestampsInput[i];
            require(
                input.validityTimestamp > _configurationsByChain[input.chainId].configuration.validityTimestamp
                    && input.validityTimestamp <= block.timestamp,
                Errors_1.INVALID_VALIDITY_TIMESTAMP
            );
            _configurationsByChain[input.chainId].configuration.validityTimestamp = input.validityTimestamp;

            emit NewInvalidation(input.validityTimestamp, input.chainId);
        }
    }

    /**
     * @notice method to update the number of confirmations necessary for the messages to be accepted as valid
     * @param newConfirmations array of objects with the chainId and the new number of needed confirmations
     */
    function _updateConfirmations(ConfirmationInput[] memory newConfirmations) internal {
        for (uint256 i; i < newConfirmations.length; i++) {
            ConfirmationInput memory confirmations = newConfirmations[i];
            require(
                confirmations.requiredConfirmations > 0
                    && confirmations.requiredConfirmations
                        <= _configurationsByChain[confirmations.chainId].allowedBridgeAdapters.length(),
                Errors_1.INVALID_REQUIRED_CONFIRMATIONS
            );
            _configurationsByChain[confirmations.chainId].configuration.requiredConfirmation =
                confirmations.requiredConfirmations;
            emit ConfirmationsUpdated(confirmations.requiredConfirmations, confirmations.chainId);
        }
    }

    /**
     * @notice method to add bridge adapters to the allowed list
     * @param bridgeAdaptersInput array of objects with the new bridge adapters and supported chains
     */
    function _updateReceiverBridgeAdapters(
        ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersInput,
        bool isAllowed
    ) internal {
        for (uint256 i = 0; i < bridgeAdaptersInput.length; i++) {
            ReceiverBridgeAdapterConfigInput memory input = bridgeAdaptersInput[i];
            require(input.bridgeAdapter != address(0), Errors_1.INVALID_BRIDGE_ADAPTER);

            for (uint256 j; j < input.chainIds.length; j++) {
                bool actionProcessed;
                if (isAllowed) {
                    _supportedChains.add(input.chainIds[j]);
                    actionProcessed =
                        _configurationsByChain[input.chainIds[j]].allowedBridgeAdapters.add(input.bridgeAdapter);
                } else {
                    actionProcessed =
                        _configurationsByChain[input.chainIds[j]].allowedBridgeAdapters.remove(input.bridgeAdapter);
                    if (
                        actionProcessed && _configurationsByChain[input.chainIds[j]].allowedBridgeAdapters.length() == 0
                    ) {
                        _supportedChains.remove(input.chainIds[j]);
                    }
                }
                if (actionProcessed) {
                    emit ReceiverBridgeAdaptersUpdated(input.bridgeAdapter, isAllowed, input.chainIds[j]);
                }
            }
        }
    }

    /// @dev utility function, defining an order of actions commonly done in batch
    function _configureReceiverBasics(
        ReceiverBridgeAdapterConfigInput[] memory bridgesToEnable,
        ReceiverBridgeAdapterConfigInput[] memory bridgesToDisable,
        ConfirmationInput[] memory newConfirmations
    ) internal {
        // IMPORTANT. Confirmations update should always happen after adapters, to not create a situation of
        // blockage in the system
        _updateReceiverBridgeAdapters(bridgesToEnable, true);
        _updateReceiverBridgeAdapters(bridgesToDisable, false);
        _updateConfirmations(newConfirmations);
    }
}

// lib/solidity-utils/src/contracts/utils/Rescuable.sol

/**
 * @title Rescuable
 * @author BGD Labs
 * @notice abstract contract with the methods to rescue tokens (ERC20 and native)  from a contract
 */
abstract contract Rescuable is RescuableBase, IRescuable {
    /// @notice modifier that checks that caller is allowed address
    modifier onlyRescueGuardian() {
        if (msg.sender != whoCanRescue()) {
            revert OnlyRescueGuardian();
        }
        _;
    }

    /// @inheritdoc IRescuable
    function emergencyTokenTransfer(address erc20Token, address to, uint256 amount)
        external
        virtual
        onlyRescueGuardian
    {
        _emergencyTokenTransfer(erc20Token, to, amount);
    }

    /// @inheritdoc IRescuable
    function emergencyEtherTransfer(address to, uint256 amount) external virtual onlyRescueGuardian {
        _emergencyEtherTransfer(to, amount);
    }

    function whoCanRescue() public view virtual returns (address);
}

// src/contracts/CrossChainForwarder.sol

/**
 * @title CrossChainForwarder
 * @author BGD Labs
 * @notice this contract contains the methods used to forward messages to different chains
 *         using registered bridge adapters.
 * @dev To be able to forward a message, caller needs to be an approved sender.
 */
contract CrossChainForwarder is UpgradeableOwnableWithGuardian, ICrossChainForwarder {
    // gap to account for previous owner & guardian
    uint256[2] internal __gap;
    // every message originator sends we put into an envelope and attach a nonce. It increments by one
    uint256 internal _currentEnvelopeNonce;

    // for every new bridging attempt of an envelope we attach a txId, that will be unique for every attempt. It increments by one
    // the rationality behind - is to be able to deliver envelope anyways, even if destination chain infra will be invalidated
    // so, we will be able to retry the envelope with the same nonce once it will recover
    uint256 internal _currentTransactionNonce;

    // specifies if an address is approved to forward messages
    mapping(address => bool) internal _approvedSenders;

    // Stores messages accepted from origin. hash(destinationChainId + (envelopeNonce, origin, destination, message)).
    // This is used to check if an envelop can be retried, in case one or more of bridges was out of gas at the forwardMessage call
    mapping(bytes32 => bool) internal _registeredEnvelopes;

    // Stores transactions sent. hash(transactionNonce, envelopeId).
    // This is used to check if a transaction can be retried
    // in a case when during the confirmation by recipient the recipient infrastructure got invalidated
    mapping(bytes32 => bool) internal _forwardedTransactions;

    // (chainId => chain configuration) list of bridge adapter configurations for a chain
    mapping(uint256 => ChainIdBridgeConfig[]) internal _bridgeAdaptersByChain;

    // configuration to limit bandwidth to only send via X bridge adapters out of the total allowed bridge adapters for
    // the specified chain
    // chainId => optimalBandwidth
    mapping(uint256 => uint256) internal _optimalBandwidthByChain;

    // storage gap allocation to be used for later updates. This way storage can be added on parent contract without
    // overwriting storage on child
    uint256[49] private __FORWARDER_GAP;

    // checks if caller is an approved sender
    modifier onlyApprovedSenders() {
        require(isSenderApproved(msg.sender), Errors_1.CALLER_IS_NOT_APPROVED_SENDER);
        _;
    }

    /**
     * @param bridgeAdaptersToEnable list of bridge adapter configurations to enable
     * @param sendersToApprove list of addresses to approve to forward messages
     */
    constructor(
        ForwarderBridgeAdapterConfigInput[] memory bridgeAdaptersToEnable,
        address[] memory sendersToApprove,
        OptimalBandwidthByChain[] memory optimalBandwidthByChain
    ) {
        _configureForwarderBasics(
            bridgeAdaptersToEnable,
            new BridgeAdapterToDisable[](0),
            sendersToApprove,
            new address[](0),
            optimalBandwidthByChain
        );
    }

    /// @inheritdoc ICrossChainForwarder
    function getOptimalBandwidthByChain(uint256 chainId) external view returns (uint256) {
        return _optimalBandwidthByChain[chainId];
    }

    /// @inheritdoc ICrossChainForwarder
    function getCurrentEnvelopeNonce() external view returns (uint256) {
        return _currentEnvelopeNonce;
    }

    /// @inheritdoc ICrossChainForwarder
    function getCurrentTransactionNonce() external view returns (uint256) {
        return _currentTransactionNonce;
    }

    /// @inheritdoc ICrossChainForwarder
    function isSenderApproved(address sender) public view returns (bool) {
        return _approvedSenders[sender];
    }

    /// @inheritdoc ICrossChainForwarder
    function isEnvelopeRegistered(Envelope memory envelope) public view returns (bool) {
        return isEnvelopeRegistered(envelope.getId());
    }

    /// @inheritdoc ICrossChainForwarder
    function isEnvelopeRegistered(bytes32 envelopeId) public view returns (bool) {
        return _registeredEnvelopes[envelopeId];
    }

    /// @inheritdoc ICrossChainForwarder
    function isTransactionForwarded(Transaction memory transaction) public view returns (bool) {
        return isTransactionForwarded(transaction.getId());
    }

    /// @inheritdoc ICrossChainForwarder
    function isTransactionForwarded(bytes32 transactionId) public view returns (bool) {
        return _forwardedTransactions[transactionId];
    }

    /// @inheritdoc ICrossChainForwarder
    function forwardMessage(uint256 destinationChainId, address destination, uint256 gasLimit, bytes memory message)
        external
        onlyApprovedSenders
        returns (bytes32, bytes32)
    {
        ChainIdBridgeConfig[] memory bridgeAdapters = _getShuffledBridgeAdaptersByChain(destinationChainId);
        require(bridgeAdapters.length > 0, Errors_1.NO_BRIDGE_ADAPTERS_FOR_SPECIFIED_CHAIN);

        uint256 envelopeNonce = _currentEnvelopeNonce++;

        Envelope memory envelope = Envelope({
            nonce: envelopeNonce,
            origin: msg.sender,
            destination: destination,
            originChainId: block.chainid,
            destinationChainId: destinationChainId,
            message: message
        });
        EncodedEnvelope memory encodedEnvelope = envelope.encode();
        // save accepted envelope for future retries in case one ore more bridges will not deliver the message to the destination
        _registeredEnvelopes[encodedEnvelope.id] = true;
        emit EnvelopeRegistered(encodedEnvelope.id, envelope);

        EncodedTransaction memory encodedTransaction =
            (Transaction({nonce: _currentTransactionNonce++, encodedEnvelope: encodedEnvelope.data})).encode();

        _forwardedTransactions[encodedTransaction.id] = true;

        _bridgeTransaction(
            encodedEnvelope.id,
            encodedTransaction.id,
            encodedTransaction.data,
            envelope.destinationChainId,
            gasLimit,
            bridgeAdapters
        );
        return (encodedEnvelope.id, encodedTransaction.id);
    }

    /// @inheritdoc ICrossChainForwarder
    function retryEnvelope(Envelope memory envelope, uint256 gasLimit) external onlyOwnerOrGuardian returns (bytes32) {
        EncodedEnvelope memory encodedEnvelope = envelope.encode();

        // Message can be retried only if it was sent before with exactly the same parameters
        require(isEnvelopeRegistered(encodedEnvelope.id), Errors_1.ENVELOPE_NOT_PREVIOUSLY_REGISTERED);

        // As envelope has not ben previously sent, we need to get the optimalBandwidth shuffled bridge adapters array again.
        ChainIdBridgeConfig[] memory bridgeAdapters = _getShuffledBridgeAdaptersByChain(envelope.destinationChainId);
        require(bridgeAdapters.length > 0, Errors_1.NO_BRIDGE_ADAPTERS_FOR_SPECIFIED_CHAIN);

        EncodedTransaction memory encodedTransaction =
            (Transaction({nonce: _currentTransactionNonce++, encodedEnvelope: encodedEnvelope.data})).encode();

        _forwardedTransactions[encodedTransaction.id] = true;

        _bridgeTransaction(
            encodedEnvelope.id,
            encodedTransaction.id,
            encodedTransaction.data,
            envelope.destinationChainId,
            gasLimit,
            bridgeAdapters
        );

        return encodedTransaction.id;
    }

    /// @inheritdoc ICrossChainForwarder
    function retryTransaction(bytes memory encodedTransaction, uint256 gasLimit, address[] memory bridgeAdaptersToRetry)
        external
        onlyOwnerOrGuardian
    {
        bytes32 transactionId = TransactionUtils.getId(encodedTransaction);
        // Transaction can be retried only if it was sent before with exactly the same parameters
        require(isTransactionForwarded(transactionId), Errors_1.TRANSACTION_NOT_PREVIOUSLY_FORWARDED);

        Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
        Envelope memory envelope = transaction.getEnvelope();

        ChainIdBridgeConfig[] memory registeredBridgeAdapters = _bridgeAdaptersByChain[envelope.destinationChainId];
        require(registeredBridgeAdapters.length > 0, Errors_1.NO_BRIDGE_ADAPTERS_FOR_SPECIFIED_CHAIN);

        ChainIdBridgeConfig[] memory bridgeAdaptersToRetryConfig =
            new ChainIdBridgeConfig[](bridgeAdaptersToRetry.length);

        for (uint256 i = 0; i < bridgeAdaptersToRetry.length; i++) {
            // check that we're not sending 2 times to the same adapter
            for (uint256 j = i + 1; j < bridgeAdaptersToRetry.length; j++) {
                require(bridgeAdaptersToRetry[i] != bridgeAdaptersToRetry[j], Errors_1.BRIDGE_ADAPTERS_SHOULD_BE_UNIQUE);
            }

            // check that adapter is valid for this networkId
            bool isAdapterRegistered = false;
            for (uint256 j = 0; j < registeredBridgeAdapters.length; j++) {
                if (bridgeAdaptersToRetry[i] == registeredBridgeAdapters[j].currentChainBridgeAdapter) {
                    bridgeAdaptersToRetryConfig[i] = registeredBridgeAdapters[j];
                    isAdapterRegistered = true;
                    break;
                }
            }
            require(isAdapterRegistered, Errors_1.INVALID_BRIDGE_ADAPTER);
        }

        bool isBridgedAtLeastOnce = _bridgeTransaction(
            transaction.getEnvelopeId(),
            transactionId,
            encodedTransaction,
            envelope.destinationChainId,
            gasLimit,
            bridgeAdaptersToRetryConfig
        );
        require(isBridgedAtLeastOnce, Errors_1.TRANSACTION_RETRY_FAILED);
    }

    /// @inheritdoc ICrossChainForwarder
    function getForwarderBridgeAdaptersByChain(uint256 chainId) external view returns (ChainIdBridgeConfig[] memory) {
        return _bridgeAdaptersByChain[chainId];
    }

    /// @inheritdoc ICrossChainForwarder
    function approveSenders(address[] memory senders) external onlyOwner {
        _updateSenders(senders, true);
    }

    /// @inheritdoc ICrossChainForwarder
    function removeSenders(address[] memory senders) external onlyOwner {
        _updateSenders(senders, false);
    }

    /// @inheritdoc ICrossChainForwarder
    function enableBridgeAdapters(ForwarderBridgeAdapterConfigInput[] memory bridgeAdapters) external onlyOwner {
        _enableBridgeAdapters(bridgeAdapters);
    }

    /// @inheritdoc ICrossChainForwarder
    function disableBridgeAdapters(BridgeAdapterToDisable[] memory bridgeAdapters) external onlyOwner {
        _disableBridgeAdapters(bridgeAdapters);
    }

    /// @inheritdoc ICrossChainForwarder
    function updateOptimalBandwidthByChain(OptimalBandwidthByChain[] memory optimalBandwidthByChain)
        external
        onlyOwner
    {
        _updateOptimalBandwidthByChain(optimalBandwidthByChain);
    }

    /**
     * @notice method to get a shuffled array of forwarder bridge adapters configurations
     * @param destinationChainId id of the destination chain to get the adapters that communicate to it
     * @return a shuffled array of the forwarder configurations for a destination chain
     */
    function _getShuffledBridgeAdaptersByChain(uint256 destinationChainId)
        internal
        view
        returns (ChainIdBridgeConfig[] memory)
    {
        uint256 optimalBandwidth = _optimalBandwidthByChain[destinationChainId];
        ChainIdBridgeConfig[] storage forwarderAdapters = _bridgeAdaptersByChain[destinationChainId];

        // If configured optimal bandwidth for a destination network are set to 0 or are bigger than current adapters,
        // it will use all the adapters available. This way there would be no way of breaking forwarding communication
        // by setting wrong configuration.
        if (optimalBandwidth == 0 || optimalBandwidth >= forwarderAdapters.length) {
            return forwarderAdapters;
        }

        uint256[] memory shuffledIndexes =
            Utils.shuffleArray(Utils.generateIndexArray(forwarderAdapters.length), optimalBandwidth);

        ChainIdBridgeConfig[] memory selectedForwarderAdapters = new ChainIdBridgeConfig[](optimalBandwidth);

        for (uint256 i = 0; i < optimalBandwidth; i++) {
            selectedForwarderAdapters[i] = forwarderAdapters[shuffledIndexes[i]];
        }

        return selectedForwarderAdapters;
    }

    /**
     * @notice internal method that has the logic to forward a transaction to the specified chain
     * @param envelopeId the id of the envelope
     * @param transactionId id of the transaction to bridge
     * @param encodedTransaction the encoded Transaction data
     * @param destinationChainId id of the chain where the transaction needs to be forwarded to
     * @param gasLimit limit of gas to spend on forwarding per bridge
     * @param bridgeAdapters list of bridge adapters to be used for the transaction forwarding
     * @return flag indicating if transaction has been forwarded at least once. The transaction id
     */
    function _bridgeTransaction(
        bytes32 envelopeId,
        bytes32 transactionId,
        bytes memory encodedTransaction,
        uint256 destinationChainId,
        uint256 gasLimit,
        ChainIdBridgeConfig[] memory bridgeAdapters
    ) internal returns (bool) {
        bool isForwardedAtLeastOnce = false;
        for (uint256 i = 0; i < bridgeAdapters.length; i++) {
            (bool success, bytes memory returnData) = bridgeAdapters[i].currentChainBridgeAdapter.delegatecall(
                abi.encodeWithSelector(
                    IBaseAdapter.forwardMessage.selector,
                    bridgeAdapters[i].destinationBridgeAdapter,
                    gasLimit,
                    destinationChainId,
                    encodedTransaction
                )
            );

            if (success) {
                isForwardedAtLeastOnce = true;
            } else {
                // it doesn't revert as sending to other bridges might succeed
            }
            emit TransactionForwardingAttempted(
                transactionId,
                envelopeId,
                encodedTransaction,
                destinationChainId,
                bridgeAdapters[i].currentChainBridgeAdapter,
                bridgeAdapters[i].destinationBridgeAdapter,
                success,
                returnData
            );
        }

        return (isForwardedAtLeastOnce);
    }

    /**
     * @notice method to enable bridge adapters
     * @param bridgeAdapters array of new bridge adapter configurations
     */
    function _enableBridgeAdapters(ForwarderBridgeAdapterConfigInput[] memory bridgeAdapters) internal {
        for (uint256 i = 0; i < bridgeAdapters.length; i++) {
            ForwarderBridgeAdapterConfigInput memory bridgeAdapterConfigInput = bridgeAdapters[i];

            require(
                bridgeAdapterConfigInput.destinationBridgeAdapter != address(0)
                    && bridgeAdapterConfigInput.currentChainBridgeAdapter != address(0),
                Errors_1.CURRENT_OR_DESTINATION_CHAIN_ADAPTER_NOT_SET
            );
            ChainIdBridgeConfig[] storage bridgeAdapterConfigs =
                _bridgeAdaptersByChain[bridgeAdapterConfigInput.destinationChainId];
            bool configFound;
            // check that we don't push same config twice.
            for (uint256 j = 0; j < bridgeAdapterConfigs.length; j++) {
                ChainIdBridgeConfig storage bridgeAdapterConfig = bridgeAdapterConfigs[j];

                if (bridgeAdapterConfig.currentChainBridgeAdapter == bridgeAdapterConfigInput.currentChainBridgeAdapter)
                {
                    if (
                        bridgeAdapterConfig.destinationBridgeAdapter
                            != bridgeAdapterConfigInput.destinationBridgeAdapter
                    ) {
                        bridgeAdapterConfig.destinationBridgeAdapter = bridgeAdapterConfigInput.destinationBridgeAdapter;

                        emit BridgeAdapterUpdated(
                            bridgeAdapterConfigInput.destinationChainId,
                            bridgeAdapterConfigInput.currentChainBridgeAdapter,
                            bridgeAdapterConfigInput.destinationBridgeAdapter,
                            true
                        );
                    }
                    configFound = true;
                    break;
                }
            }

            if (!configFound) {
                // preparing fees stream
                // Address.functionDelegateCall(
                //   bridgeAdapterConfigInput.currentChainBridgeAdapter,
                //   abi.encodeWithSelector(IBaseAdapter.setupPayments.selector),
                //   Errors.ADAPTER_PAYMENT_SETUP_FAILED
                // ); // TODO

                bridgeAdapterConfigs.push(
                    ChainIdBridgeConfig({
                        destinationBridgeAdapter: bridgeAdapterConfigInput.destinationBridgeAdapter,
                        currentChainBridgeAdapter: bridgeAdapterConfigInput.currentChainBridgeAdapter
                    })
                );

                emit BridgeAdapterUpdated(
                    bridgeAdapterConfigInput.destinationChainId,
                    bridgeAdapterConfigInput.currentChainBridgeAdapter,
                    bridgeAdapterConfigInput.destinationBridgeAdapter,
                    true
                );
            }
        }
    }

    /**
     * @notice method to disable bridge adapters
     * @param bridgeAdaptersToDisable array of bridge adapter addresses to disable
     */
    function _disableBridgeAdapters(BridgeAdapterToDisable[] memory bridgeAdaptersToDisable) internal {
        for (uint256 i = 0; i < bridgeAdaptersToDisable.length; i++) {
            for (uint256 j = 0; j < bridgeAdaptersToDisable[i].chainIds.length; j++) {
                ChainIdBridgeConfig[] storage bridgeAdapterConfigs =
                    _bridgeAdaptersByChain[bridgeAdaptersToDisable[i].chainIds[j]];

                for (uint256 k = 0; k < bridgeAdapterConfigs.length; k++) {
                    if (bridgeAdapterConfigs[k].currentChainBridgeAdapter == bridgeAdaptersToDisable[i].bridgeAdapter) {
                        address destinationBridgeAdapter = bridgeAdapterConfigs[k].destinationBridgeAdapter;

                        bridgeAdapterConfigs[k] = bridgeAdapterConfigs[bridgeAdapterConfigs.length - 1];
                        bridgeAdapterConfigs.pop();

                        emit BridgeAdapterUpdated(
                            bridgeAdaptersToDisable[i].chainIds[j],
                            bridgeAdaptersToDisable[i].bridgeAdapter,
                            destinationBridgeAdapter,
                            false
                        );
                        break;
                    }
                }
            }
        }
    }

    /**
     * @notice method to approve or disapprove a list of senders
     * @param senders list of addresses to update
     * @param newState indicates if the list of senders will be approved or disapproved
     */
    function _updateSenders(address[] memory senders, bool newState) internal {
        for (uint256 i = 0; i < senders.length; i++) {
            require(senders[i] != address(0), Errors_1.INVALID_SENDER);
            _approvedSenders[senders[i]] = newState;
            emit SenderUpdated(senders[i], newState);
        }
    }

    /**
     * @notice method to update the optimal bandwidth of a receiver chain
     * @param optimalBandwidthByChain array of objects containing the optimal bandwidth for a specified receiver chain id
     * @dev Setting optimal bandwidth to 0 means that no optimization will be applied, so all allowed bridges will be used to
     *      forward a message.
     */
    function _updateOptimalBandwidthByChain(OptimalBandwidthByChain[] memory optimalBandwidthByChain) internal {
        for (uint256 i = 0; i < optimalBandwidthByChain.length; i++) {
            _optimalBandwidthByChain[optimalBandwidthByChain[i].chainId] = optimalBandwidthByChain[i].optimalBandwidth;

            emit OptimalBandwidthUpdated(
                optimalBandwidthByChain[i].chainId, optimalBandwidthByChain[i].optimalBandwidth
            );
        }
    }

    /// @dev utility function, defining an order of actions commonly done in batch
    function _configureForwarderBasics(
        ForwarderBridgeAdapterConfigInput[] memory bridgesToEnable,
        BridgeAdapterToDisable[] memory bridgesToDisable,
        address[] memory sendersToEnable,
        address[] memory sendersToDisable,
        OptimalBandwidthByChain[] memory optimalBandwidthByChain
    ) internal {
        _enableBridgeAdapters(bridgesToEnable);
        _disableBridgeAdapters(bridgesToDisable);
        _updateSenders(sendersToEnable, true);
        _updateSenders(sendersToDisable, false);
        _updateOptimalBandwidthByChain(optimalBandwidthByChain);
    }
}

// src/contracts/BaseCrossChainController.sol

/**
 * @title BaseCrossChainController
 * @author BGD Labs
 * @notice Contract with the logic to manage sending and receiving messages cross chain.
 * @dev This contract is enabled to receive gas tokens as its the one responsible for bridge services payment.
 *         It should always be topped up, or no messages will be sent to other chains
 */
contract BaseCrossChainController is IBaseCrossChainController, Rescuable, CrossChainForwarder, CrossChainReceiver {
    constructor()
        CrossChainReceiver(new ConfirmationInput[](0), new ReceiverBridgeAdapterConfigInput[](0))
        CrossChainForwarder(new ForwarderBridgeAdapterConfigInput[](0), new address[](0), new OptimalBandwidthByChain[](0))
    {
        _disableInitializers();
    }

    /// @dev child class should make a call of this method
    function _baseInitialize(
        address owner,
        address guardian,
        ConfirmationInput[] memory initialRequiredConfirmations,
        ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
        ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
        address[] memory sendersToApprove,
        OptimalBandwidthByChain[] memory optimalBandwidthByChain
    ) internal initializer {
        __Ownable_With_Guardian_init(owner, guardian);

        _configureReceiverBasics(
            receiverBridgeAdaptersToAllow,
            new ReceiverBridgeAdapterConfigInput[](0), // On first init, no bridges to disable
            initialRequiredConfirmations
        );

        _configureForwarderBasics(
            forwarderBridgeAdaptersToEnable,
            new BridgeAdapterToDisable[](0), // On first init, no bridges to disable
            sendersToApprove,
            new address[](0), // On first init, no senders to unauthorize
            optimalBandwidthByChain
        );
    }

    /// @inheritdoc Rescuable
    function whoCanRescue() public view override(Rescuable) returns (address) {
        return owner();
    }

    /// @inheritdoc IRescuableBase
    function maxRescue(address erc20Token) public view override(IRescuableBase, RescuableBase) returns (uint256) {
        return IERC20(erc20Token).balanceOf(address(this));
    }

    /// @notice Enable contract to receive ETH/Native token
    receive() external payable {}
}

// src/contracts/CrossChainController.sol

/**
 * @title CrossChainController
 * @author BGD Labs
 * @notice CrossChainController contract adopted for usage on the chain where Governance deployed (mainnet in our case)
 */
contract CrossChainController is ICrossChainController, BaseCrossChainController {
    /// @inheritdoc ICrossChainController
    function initialize(
        address owner,
        address guardian,
        ConfirmationInput[] memory initialRequiredConfirmations,
        ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
        ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
        address[] memory sendersToApprove,
        OptimalBandwidthByChain[] memory optimalBandwidthByChain
    ) external initializer {
        _baseInitialize(
            owner,
            guardian,
            initialRequiredConfirmations,
            receiverBridgeAdaptersToAllow,
            forwarderBridgeAdaptersToEnable,
            sendersToApprove,
            optimalBandwidthByChain
        );
    }
}
