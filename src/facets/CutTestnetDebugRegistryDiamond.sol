// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/LibTestnetDebugRegistry.sol";
import "../../lib/cu-osc-diamond-template/src/diamond/CutDiamond.sol";
import "../../lib/cu-osc-common/src/interfaces/ITestnetDebugRegistry.sol";

/// @title Dummy "implementation" contract for Debug Registry interface for ERC-1967 compatibility
/// @dev This interface is used to call endpoints on a deployed DebugRegistry diamond cluster.
contract CutTestnetDebugRegistryDiamond is CutDiamond {
    /// @notice Global debugging state on the entire testnet
    /// @return enabled true if global debugging is enabled
    function globalDebuggingEnabled() external view returns (bool enabled) {}

    /// @notice Enable debugging on the entire testnet
    /// @notice Admin only
    function enableGlobalDebugging() external {}

    /// @notice Disable debugging on the entire testnet
    /// @notice Any Admin or debugger can call this
    function disableGlobalDebugging() external {}

    /// @notice Give an account admin permissions
    /// @notice Any Admin can call this
    /// @param account Wallet to give admin permissions to
    function registerAdmin(address account) external {}

    /// @notice Give an account debugger permissions
    /// @notice Any Admin or Debugger can call this
    /// @param account Wallet to give debugger permissions to
    function registerDebugger(address account) external {}

    /// @notice Ban an account from debugging on the entire testnet
    /// @notice Any Admin or Debugger can call this
    /// @param account Wallet to ban
    function ban(address account) external {}

    /// @notice Remove Admin and Debugger permissions from an account
    /// @notice Only Admins can call this
    /// @param account Wallet to remove permissions from
    function removePermissions(address account) external {}

    /// @notice Unban an account from debugging on the entire testnet
    /// @notice Only Admins can call this
    /// @param account Wallet to unban
    function liftBan(address account) external {}

    /// @notice Return the permissions for an account
    /// @param account Wallet to check
    /// @return role Current permissions for the account
    function role(
        address account
    ) external view returns (ITestnetDebugRegistry.Role memory) {}

    /// @notice Return a list of all accounts in the system
    /// @return accounts List of all accounts
    function accounts() external view returns (address[] memory) {}

    /// @notice Return the current chainid
    /// @return chainId Current chainid
    function chainId() external view returns (uint256) {}

    /// @notice Return if the current chainid is a known mainnet
    /// @return isMainnet True if the current chainid is a known mainnet
    function isMainnet() external view returns (bool) {}

    /// @notice Return if the current chainid is a known testnet
    /// @return isTestnet True if the current chainid is a known testnet
    function isTestnet() external view returns (bool) {}

    /// @notice Throws an error if global debugging is not enabled
    /// @custom:throws GlobalDebuggingDisabled
    function enforceGlobalDebuggingEnabled() external view {}

    /// @notice Throws an error if the current chainid is not a known mainnet
    /// @custom:throws InvalidBlockchain
    function enforceTestnet() external view {}

    /// @notice Throws an error if the target account is banned
    /// @param account Wallet to check
    /// @custom:throws GlobalDebuggingDisabled
    /// @custom:throws AddressIsBanned
    function enforceNotBanned(address account) external view {}

    /// @notice Throws an error if the target account is not an Admin
    /// @param account Wallet to check
    /// @custom:throws GlobalDebuggingDisabled
    /// @custom:throws AddressIsBanned
    /// @custom:throws AddressIsNotAdmin
    function enforceAdmin(address account) external view {}

    /// @notice Throws an error if the target account is not a Debugger (or Admin)
    /// @param account Wallet to check
    /// @custom:throws GlobalDebuggingDisabled
    /// @custom:throws AddressIsBanned
    /// @custom:throws AddressIsNotDebugger
    function enforceDebugger(address account) external view {}

    /// @notice Return if the target account is an Admin
    /// @param account Wallet to check
    /// @return isAdmin True if the target account is an Admin
    function isAdmin(address account) external view returns (bool) {}

    /// @notice Return if the target account is a Debugger
    /// @param account Wallet to check
    /// @return isDebugger True if the target account is a Debugger
    function isDebugger(address account) external view returns (bool) {}

    /// @notice Return if the target account is banned
    /// @param account Wallet to check
    /// @return isBanned True if the target account is banned
    function isBanned(address account) external view returns (bool) {}

    /// @notice Return if the target account has ever been added in the system
    /// @param account Wallet to check
    /// @return existsInSystem True if the target account exists in the system
    function existsInSystem(address account) external view returns (bool) {}
}
