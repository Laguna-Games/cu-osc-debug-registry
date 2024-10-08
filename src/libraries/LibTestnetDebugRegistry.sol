// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";

import "../../lib/cu-osc-common/src/interfaces/ITestnetDebugRegistry.sol";

/// @title LG Testnet Debug Registry
/// @author rsampson@laguna.games
/// @notice Library for debug permissions common across all diamonds
/// @custom:storage-location erc7201:games.laguna.LibTestnetDebugRegistry
library LibTestnetDebugRegistry {
    error GlobalDebuggingDisabled();
    error InvalidBlockchain(uint chainId);

    error AddressIsBanned(address account);
    error AddressIsNotAdmin(address account);
    error AddressIsNotDebugger(address account);

    //  PRODUCTION MAINNETS - NO DEBUG ALLOWED!
    uint256 internal constant ETHEREUM_CHAIN_ID = 1;
    uint256 internal constant POLYGON_CHAIN_ID = 137;
    uint256 internal constant ARBITRUM_ONE_CHAIN_ID = 42161;
    uint256 internal constant ARBITRUM_NOVA_CHAIN_ID = 42170;
    uint256 internal constant XAI_CHAIN_ID = 660279;

    //  TESTNETS
    uint256 internal constant GOERLI_CHAIN_ID = 5;
    uint256 internal constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 internal constant MUMBAI_CHAIN_ID = 80001;
    uint256 internal constant ARBITRUM_GOERLI_CHAIN_ID = 421613;
    uint256 internal constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;
    uint256 internal constant XAI_GOERLI_CHAIN_ID = 47279324479;
    uint256 internal constant XAI_SEPOLIA_CHAIN_ID = 37714555429;
    uint256 internal constant LOCAL_HARDHAT_CHAIN_ID = 31337; // This is the same for Foundry and Brownie
    uint256 internal constant LOCAL_GANACHE_CHAIN_ID = 1337;

    //  @dev Storage slot for LG Resource addresses
    bytes32 internal constant TESTNET_DEBUG_REGISTRY_SLOT_POSITION =
        keccak256(
            abi.encode(
                uint256(keccak256("games.laguna.LibTestnetDebugRegistry")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    // ITestnetDebugRegistry
    // struct Role {
    //     bool existsInSystem;
    //     bool admin;
    //     bool debugger;
    //     bool banned;
    // }

    struct TestnetDebugRegistryStorageStruct {
        mapping(address wallet => ITestnetDebugRegistry.Role role) roles;
        address[] accounts;
        bool globalDebuggingEnabled;
    }

    /// @notice Storage slot for ResourceLocator state data
    function testnetDebugRegistryStorage()
        internal
        pure
        returns (TestnetDebugRegistryStorageStruct storage storageSlot)
    {
        bytes32 position = TESTNET_DEBUG_REGISTRY_SLOT_POSITION;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            storageSlot.slot := position
        }
    }

    function globalDebuggingEnabled() internal view returns (bool) {
        return testnetDebugRegistryStorage().globalDebuggingEnabled;
    }

    function setGlobalDebuggingEnabled(bool enabled) internal {
        testnetDebugRegistryStorage().globalDebuggingEnabled = enabled;
    }

    function setAdmin(address account) internal {
        TestnetDebugRegistryStorageStruct
            storage ss = testnetDebugRegistryStorage();
        if (!ss.roles[account].existsInSystem) {
            ss.roles[account].existsInSystem = true;
            ss.accounts.push(account);
        }
        ss.roles[account].admin = true;
    }

    function setDebugger(address account) internal {
        TestnetDebugRegistryStorageStruct
            storage ss = testnetDebugRegistryStorage();
        if (!ss.roles[account].existsInSystem) {
            ss.roles[account].existsInSystem = true;
            ss.accounts.push(account);
        }
        ss.roles[account].debugger = true;
    }

    function removePermissions(address account) internal {
        if (account == LibContractOwner.contractOwner()) {
            revert("Permissions cannot be removed from the contract owner.");
        }

        testnetDebugRegistryStorage().roles[account].admin = false;
        testnetDebugRegistryStorage().roles[account].debugger = false;
    }

    function ban(address account) internal {
        if (account == LibContractOwner.contractOwner())
            revert("Contract owner cannot be banned");
        TestnetDebugRegistryStorageStruct
            storage ss = testnetDebugRegistryStorage();
        if (!ss.roles[account].existsInSystem) {
            ss.roles[account].existsInSystem = true;
            ss.accounts.push(account);
        }
        ss.roles[account].banned = true;
    }

    function liftBan(address account) internal {
        testnetDebugRegistryStorage().roles[account].banned = false;
    }

    function getRole(
        address account
    ) internal view returns (ITestnetDebugRegistry.Role memory) {
        return testnetDebugRegistryStorage().roles[account];
    }

    function accounts() internal view returns (address[] memory) {
        return testnetDebugRegistryStorage().accounts;
    }

    //  Returns true if chainId is a known mainnet
    function isKnownMainnet(uint256 chainId) internal pure returns (bool) {
        return
            chainId == ETHEREUM_CHAIN_ID ||
            chainId == POLYGON_CHAIN_ID ||
            chainId == ARBITRUM_ONE_CHAIN_ID ||
            chainId == ARBITRUM_NOVA_CHAIN_ID ||
            chainId == XAI_CHAIN_ID;
    }

    //  Returns true if chainId is a known testnet
    function isKnownTestnet(uint256 chainId) internal pure returns (bool) {
        return
            chainId == GOERLI_CHAIN_ID ||
            chainId == SEPOLIA_CHAIN_ID ||
            chainId == MUMBAI_CHAIN_ID ||
            chainId == ARBITRUM_GOERLI_CHAIN_ID ||
            chainId == ARBITRUM_SEPOLIA_CHAIN_ID ||
            chainId == XAI_GOERLI_CHAIN_ID ||
            chainId == XAI_SEPOLIA_CHAIN_ID ||
            chainId == LOCAL_HARDHAT_CHAIN_ID ||
            chainId == LOCAL_GANACHE_CHAIN_ID;
    }

    function enforceGlobalDebuggingEnabled() internal view {
        if (!testnetDebugRegistryStorage().globalDebuggingEnabled) {
            revert GlobalDebuggingDisabled();
        }
    }

    function enforceTestnet() internal view {
        if (isKnownMainnet(block.chainid))
            revert InvalidBlockchain(block.chainid);
        if (!isKnownTestnet(block.chainid))
            revert InvalidBlockchain(block.chainid);
    }

    function enforceNotBanned(address account) internal view {
        if (isBanned(account)) revert AddressIsBanned(account);
    }

    function enforceAdmin(address account) internal view {
        enforceNotBanned(account);
        ITestnetDebugRegistry.Role memory role = testnetDebugRegistryStorage()
            .roles[account];
        if (!role.admin) revert AddressIsNotAdmin(account);
    }

    function enforceDebugger(address account) internal view {
        enforceNotBanned(account);
        ITestnetDebugRegistry.Role memory role = testnetDebugRegistryStorage()
            .roles[account];
        if (!role.debugger && !role.admin) revert AddressIsNotDebugger(account);
    }

    function isAdmin(address account) internal view returns (bool) {
        return testnetDebugRegistryStorage().roles[account].admin;
    }

    function isDebugger(address account) internal view returns (bool) {
        return testnetDebugRegistryStorage().roles[account].debugger;
    }

    function isBanned(address account) internal view returns (bool) {
        return testnetDebugRegistryStorage().roles[account].banned;
    }

    function existsInSystem(address account) internal view returns (bool) {
        return testnetDebugRegistryStorage().roles[account].existsInSystem;
    }
}
