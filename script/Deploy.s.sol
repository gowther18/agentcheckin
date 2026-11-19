// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AgentCheckin.sol";

/// @notice Deploys AgentCheckin against the live SPACE ID Agent ID registry.
/// @dev Run with: forge script script/Deploy.s.sol --rpc-url <bsc-rpc>
///      --private-key <key> --broadcast
///      NOT run yet — deployment is a separate, later step.
contract Deploy is Script {
    // SPACE ID Agent ID registry (BNB Chain).
    address public constant AGENT_ID_REGISTRY =
        0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    function run() external returns (AgentCheckin) {
        vm.startBroadcast();
        AgentCheckin checkin = new AgentCheckin(AGENT_ID_REGISTRY);
        vm.stopBroadcast();
        return checkin;
    }
}
