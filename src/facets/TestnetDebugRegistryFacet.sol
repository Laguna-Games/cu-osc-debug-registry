// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/LibTestnetDebugRegistry.sol";
import "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";
import "../../lib/cu-osc-common/src/interfaces/ITestnetDebugRegistry.sol";

/// @title Resource Locator Admin facet for Crypto Unicorns
/// @author rsampson@laguna.games
contract TestnetDebugRegistryFacet is ITestnetDebugRegistry {
    /// @notice Global debugging state on the entire testnet
    /// @return enabled true if global debugging is enabled
    function globalDebuggingEnabled() external view returns (bool enabled) {
        enabled = LibTestnetDebugRegistry.globalDebuggingEnabled();
    }

    /// @notice Enable debugging on the entire testnet
    /// @notice Admin only
    function enableGlobalDebugging() external {
        LibTestnetDebugRegistry.enforceTestnet();
        LibContractOwner.enforceIsContractOwner();
        LibTestnetDebugRegistry.setGlobalDebuggingEnabled(true);
        LibTestnetDebugRegistry.setAdmin(LibContractOwner.contractOwner());
    }

    /// @notice Disable debugging on the entire testnet
    /// @notice Any Admin or debugger can call this
    function disableGlobalDebugging() external {
        LibTestnetDebugRegistry.enforceTestnet();
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceDebugger(msg.sender);
        LibTestnetDebugRegistry.setGlobalDebuggingEnabled(false);
    }

    /// @notice Give an account admin permissions
    /// @notice Any Admin can call this
    /// @param account Wallet to give admin permissions to
    function registerAdmin(address account) external {
        LibTestnetDebugRegistry.enforceTestnet();
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceAdmin(msg.sender);
        LibTestnetDebugRegistry.setAdmin(account);
    }

    /// @notice Give an account debugger permissions
    /// @notice Any Admin or Debugger can call this
    /// @param account Wallet to give debugger permissions to
    function registerDebugger(address account) external {
        LibTestnetDebugRegistry.enforceTestnet();
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceDebugger(msg.sender);
        LibTestnetDebugRegistry.setDebugger(account);
    }

    /// @notice Ban an account from debugging on the entire testnet
    /// @notice Any Admin or Debugger can call this
    /// @param account Wallet to ban
    function ban(address account) external {
        // LibTestnetDebugRegistry.enforceTestnet();
        // LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceDebugger(msg.sender);
        LibTestnetDebugRegistry.ban(account);
    }

    /// @notice Remove Admin and Debugger permissions from an account
    /// @notice Only Admins can call this
    /// @param account Wallet to remove permissions from
    function removePermissions(address account) external {
        LibTestnetDebugRegistry.enforceAdmin(msg.sender);
        LibTestnetDebugRegistry.removePermissions(account);
    }

    /// @notice Unban an account from debugging on the entire testnet
    /// @notice Only Admins can call this
    /// @param account Wallet to unban
    function liftBan(address account) external {
        LibTestnetDebugRegistry.enforceTestnet();
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceAdmin(msg.sender);
        LibTestnetDebugRegistry.liftBan(account);
    }

    /// @notice Return the permissions for an account
    /// @param account Wallet to check
    /// @return role Current permissions for the account
    function role(
        address account
    ) external view returns (ITestnetDebugRegistry.Role memory) {
        return LibTestnetDebugRegistry.getRole(account);
    }

    /// @notice Return a list of all accounts in the system
    /// @return accounts List of all accounts
    function accounts() external view returns (address[] memory) {
        return LibTestnetDebugRegistry.accounts();
    }

    /// @notice Return the current chainid
    /// @return chainId Current chainid
    function chainId() external view returns (uint256) {
        return block.chainid;
    }

    /// @notice Return if the current chainid is a known mainnet
    /// @return isMainnet True if the current chainid is a known mainnet
    function isMainnet() external view returns (bool) {
        return LibTestnetDebugRegistry.isKnownMainnet(block.chainid);
    }

    /// @notice Return if the current chainid is a known testnet
    /// @return isTestnet True if the current chainid is a known testnet
    function isTestnet() external view returns (bool) {
        return LibTestnetDebugRegistry.isKnownTestnet(block.chainid);
    }

    /// @notice Throws an error if global debugging is not enabled
    /// @custom:throws GlobalDebuggingDisabled
    function enforceGlobalDebuggingEnabled() external view {
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
    }

    /// @notice Throws an error if the current chainid is not a known mainnet
    /// @custom:throws InvalidBlockchain
    function enforceTestnet() external view {
        LibTestnetDebugRegistry.enforceTestnet();
    }

    /// @notice Throws an error if the target account is banned
    /// @param account Wallet to check
    /// @custom:throws GlobalDebuggingDisabled
    /// @custom:throws AddressIsBanned
    function enforceNotBanned(address account) external view {
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceNotBanned(account);
    }

    /// @notice Throws an error if the target account is not an Admin
    /// @param account Wallet to check
    /// @custom:throws GlobalDebuggingDisabled
    /// @custom:throws AddressIsBanned
    /// @custom:throws AddressIsNotAdmin
    function enforceAdmin(address account) external view {
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceAdmin(account);
    }

    /// @notice Throws an error if the target account is not a Debugger (or Admin)
    /// @param account Wallet to check
    /// @custom:throws GlobalDebuggingDisabled
    /// @custom:throws AddressIsBanned
    /// @custom:throws AddressIsNotDebugger
    function enforceDebugger(address account) external view {
        LibTestnetDebugRegistry.enforceGlobalDebuggingEnabled();
        LibTestnetDebugRegistry.enforceDebugger(account);
    }

    /// @notice Return if the target account is an Admin
    /// @param account Wallet to check
    /// @return isAdmin True if the target account is an Admin
    function isAdmin(address account) external view returns (bool) {
        return LibTestnetDebugRegistry.isAdmin(account);
    }

    /// @notice Return if the target account is a Debugger (NOT an Admin)
    /// @param account Wallet to check
    /// @return isDebugger True if the target account is a Debugger
    function isDebugger(address account) external view returns (bool) {
        return LibTestnetDebugRegistry.isDebugger(account);
    }

    /// @notice Return if the target account is banned
    /// @param account Wallet to check
    /// @return isBanned True if the target account is banned
    function isBanned(address account) external view returns (bool) {
        return LibTestnetDebugRegistry.isBanned(account);
    }

    /// @notice Return if the target account has ever been added in the system
    /// @param account Wallet to check
    /// @return existsInSystem True if the target account exists in the system
    function existsInSystem(address account) external view returns (bool) {
        return LibTestnetDebugRegistry.existsInSystem(account);
    }
}
