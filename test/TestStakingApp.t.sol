// SPDX-License-Identifier: MIT
// SPDX-License: MIT

pragma solidity 0.8.28;

import "../lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
//import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestStakingApp is Test {
    
    StakingToken stakingToken;
    StakingApp stakingApp; // initialize smart contract

    // StakingToken Parameters
    string name = "BB Token";
    string symbol = "BBT";

    // StakingApp Parameters
    address owner = vm.addr(1);
    address randomUser = vm.addr(2);
    uint256 stakingPeriod = 86400;
    uint256 fixedStakingAmount = 10;
    uint256 rewardPerPeriod = 1 ether;

    function setUp() external {
        stakingToken = new StakingToken(name, symbol);
        stakingApp = new StakingApp(address(stakingToken), owner, stakingPeriod, fixedStakingAmount, rewardPerPeriod);
    }

    function testStakingTokenDeployed() external view {
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppDeployed() external view {
        assert(address(stakingApp) != address(0));
    }

    function testShouldRevertIfNotOwner() external {
        
        uint256 newStakingPeriod_ = 12345;

        vm.expectRevert();
        stakingApp.updateStakingPeriod(newStakingPeriod_);
    }

    function testShouldUpdateStakingPeriod() external {
        vm.startPrank(owner);
        uint256 newStakingPeriod_ = 12345;

        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
        stakingApp.updateStakingPeriod(newStakingPeriod_);
        uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodBefore != stakingPeriodAfter);
        assert(stakingPeriodAfter == newStakingPeriod_);
        vm.stopPrank();
    }

    function testContractCanReceiveEther() external {
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);

        uint256 etherValue = 1 ether;
        uint256 balanceBefore = address(stakingApp).balance;
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingApp).balance;
        require(success, "Transfer failed.");

        assert(balanceAfter == balanceBefore + etherValue);

        vm.stopPrank();
    }

    function testIncorrectAmountShouldRevert() external {
        vm.startPrank(randomUser);

        uint256 amount_ = 1;
        vm.expectRevert("Wrong amount");
        stakingApp.depositTokens(amount_);

        vm.stopPrank();
    }

    function testDepositTokensCorrectly() external {
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.depositTimestamp(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.depositTimestamp(randomUser);
        
        assert(userBalanceAfter == tokenAmount + userBalanceBefore);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.stopPrank();
    }

    function testCanNotDepositMoreThanOnce() external {
        // Deposit > Approve > Deposti > Revert expected
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.depositTimestamp(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.depositTimestamp(randomUser);
        
        assert(userBalanceAfter == tokenAmount + userBalanceBefore);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        stakingToken.mint(tokenAmount);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        vm.expectRevert("Already Deposited Tokens");
        stakingApp.depositTokens(tokenAmount);

        vm.stopPrank();
    }

    function testCanOnlyWithdraw0WithoutDeposit() external {
        vm.startPrank(randomUser);
        
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        
        assert(userBalanceBefore == userBalanceAfter);

        vm.stopPrank();
    }

    function testUserCanWithdrawtokens() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.depositTimestamp(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.depositTimestamp(randomUser);
        
        assert(userBalanceAfter == tokenAmount + userBalanceBefore);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        uint256 userBalanceBeforeWithdraw = IERC20(stakingToken).balanceOf(randomUser);
        uint256 userBalanceInMapping = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfterWithdraw = IERC20(stakingToken).balanceOf(randomUser);

        assert(userBalanceAfterWithdraw == userBalanceBeforeWithdraw + userBalanceInMapping);

        vm.stopPrank();
    }

    // ClaimRewards Function Tests

    function testCanNotClaimIfNotStaking() external {
        vm.startPrank(randomUser);

        vm.expectRevert("User is not staking.");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCanNotClaimIfNotElapsedTime() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.depositTimestamp(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.depositTimestamp(randomUser);
        
        assert(userBalanceAfter == tokenAmount + userBalanceBefore);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.expectRevert("Wait to claim rewards.");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testShouldRevertIfNoEther() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.depositTimestamp(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.depositTimestamp(randomUser);
        
        assert(userBalanceAfter == tokenAmount + userBalanceBefore);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.warp(block.timestamp + stakingPeriod);
        vm.expectRevert("Transfer failed");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCanClaimRewardsIfElapsedTimeAndFunds() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.depositTimestamp(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.depositTimestamp(randomUser);
        
        assert(userBalanceAfter == tokenAmount + userBalanceBefore);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.stopPrank();

        vm.startPrank(owner);
        uint256 etherAmount = 2 ether;
        vm.deal(owner, etherAmount);
        (bool success,) = address(stakingApp).call{value: etherAmount}("");
        require(success, "Transfer failed.");        
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.warp(block.timestamp + stakingPeriod);
        uint256 etherAmountBefore = address(randomUser).balance;
        stakingApp.claimRewards();
        uint256 etherAmountAfter = address(randomUser).balance;
        uint256 elapsedPeriod = stakingApp.depositTimestamp(randomUser);

        assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod);
        assert(elapsedPeriod == block.timestamp);

        vm.stopPrank();
    }
}