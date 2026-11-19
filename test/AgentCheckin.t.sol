// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AgentCheckin.sol";

/// @notice Minimal mock of the SPACE ID Agent ID registry (ERC-721).
/// @dev Only implements balanceOf + a mint helper; the real registry is
///      non-transferable, but that does not matter for these tests.
contract MockAgentID {
    mapping(address => uint256) public balanceOf;

    function mint(address to) external {
        balanceOf[to]++;
    }
}

contract AgentCheckinTest is Test {
    AgentCheckin public checkin;
    MockAgentID public registry;

    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);
    address public carol = address(0xCA901);

    // Realistic "now": 2026-11-19 06:40 UTC. Warping to a realistic
    // timestamp matters: day 0 (block.timestamp < 1 days) would collide
    // with the zero-value of lastCheckinDay for never-checked-in users.
    uint256 public constant T0 = 1795060800;

    function setUp() public {
        vm.warp(T0);
        registry = new MockAgentID();
        checkin = new AgentCheckin(address(registry));
        registry.mint(alice);
        registry.mint(bob);
        // carol never receives an Agent ID on purpose.
    }

    function testNonHolderReverts() public {
        vm.prank(carol);
        vm.expectRevert("Not an Agent ID holder");
        checkin.checkIn();
    }

    function testFirstCheckinSetsStreakOne() public {
        vm.prank(alice);
        checkin.checkIn();

        assertEq(checkin.getStreak(alice), 1);
        assertEq(checkin.getTotalCheckins(alice), 1);
        assertEq(checkin.totalCheckinsAll(), 1);
        assertEq(checkin.getLastCheckinDay(alice), T0 / 1 days);
    }

    function testConsecutiveDayIncrementsStreak() public {
        vm.prank(alice);
        checkin.checkIn();

        vm.warp(T0 + 1 days);
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 2);

        vm.warp(T0 + 2 days);
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 3);
        assertEq(checkin.getTotalCheckins(alice), 3);
        assertEq(checkin.totalCheckinsAll(), 3);
    }

    function testSameDaySecondCheckinReverts() public {
        vm.prank(alice);
        checkin.checkIn();

        vm.prank(alice);
        vm.expectRevert("Already checked in today");
        checkin.checkIn();

        // Streak and totals unchanged by the failed call.
        assertEq(checkin.getStreak(alice), 1);
        assertEq(checkin.getTotalCheckins(alice), 1);
    }

    function testGapDayResetsStreakToOne() public {
        vm.prank(alice);
        checkin.checkIn(); // day 0, streak 1

        vm.warp(T0 + 1 days);
        vm.prank(alice);
        checkin.checkIn(); // day 1, streak 2

        vm.warp(T0 + 3 days); // skipped day 2 entirely
        vm.prank(alice);
        checkin.checkIn(); // day 3, streak back to 1

        assertEq(checkin.getStreak(alice), 1);
        assertEq(checkin.getTotalCheckins(alice), 3);
    }

    function testTotalsAccumulateAcrossUsers() public {
        vm.prank(alice);
        checkin.checkIn();
        vm.prank(bob);
        checkin.checkIn();
        assertEq(checkin.totalCheckinsAll(), 2);

        vm.warp(T0 + 1 days);
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.totalCheckinsAll(), 3);
        assertEq(checkin.getTotalCheckins(alice), 2);
        assertEq(checkin.getTotalCheckins(bob), 1);
    }

    function testEmitsCheckInEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit AgentCheckin.CheckIn(alice, T0 / 1 days, 1);
        checkin.checkIn();
    }
}
