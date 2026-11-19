// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AgentCheckin
/// @notice Daily check-in + streak tracker for Binance Agent ID holders.
/// @dev Only addresses holding a SPACE ID Agent ID (ERC-721, non-transferable)
///      can check in. Holder status is verified on-chain by calling balanceOf()
///      on the Agent ID registry. No owner, no admin, no fees, no pausing.
interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);
}

contract AgentCheckin {
    /// @notice SPACE ID Agent ID registry (BNB Chain).
    /// @dev Passed in the constructor so the contract is testable with a mock
    ///      registry. Deploy with 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F.
    IERC721 public immutable agentIdRegistry;

    /// @notice Last day (unix timestamp / 1 days) an address checked in.
    mapping(address => uint256) public lastCheckinDay;

    /// @notice Current consecutive-day streak per address.
    mapping(address => uint256) public streak;

    /// @notice Total check-ins per address.
    mapping(address => uint256) public totalCheckins;

    /// @notice Total check-ins across all users.
    uint256 public totalCheckinsAll;

    /// @notice Emitted on every successful check-in.
    event CheckIn(address indexed user, uint256 indexed day, uint256 streak);

    constructor(address _agentIdRegistry) {
        agentIdRegistry = IERC721(_agentIdRegistry);
    }

    /// @notice Check in once per day. Only Agent ID holders can call this.
    /// @dev A streak continues only when the previous check-in was yesterday;
    ///      any gap resets the streak to 1.
    function checkIn() external {
        require(
            agentIdRegistry.balanceOf(msg.sender) > 0,
            "Not an Agent ID holder"
        );
        uint256 today = block.timestamp / 1 days;
        require(
            lastCheckinDay[msg.sender] != today,
            "Already checked in today"
        );
        if (lastCheckinDay[msg.sender] == today - 1) {
            streak[msg.sender]++;
        } else {
            streak[msg.sender] = 1;
        }
        lastCheckinDay[msg.sender] = today;
        totalCheckins[msg.sender]++;
        totalCheckinsAll++;
        emit CheckIn(msg.sender, today, streak[msg.sender]);
    }

    /// @notice Current streak of an address.
    function getStreak(address user) external view returns (uint256) {
        return streak[user];
    }

    /// @notice Total check-ins of an address.
    function getTotalCheckins(address user) external view returns (uint256) {
        return totalCheckins[user];
    }

    /// @notice Last check-in day (unix timestamp / 1 days) of an address.
    function getLastCheckinDay(address user) external view returns (uint256) {
        return lastCheckinDay[user];
    }
}
