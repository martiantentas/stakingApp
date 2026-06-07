// SPDX-License-Identifier: MIT
// SPDX-License: MIT

pragma solidity 0.8.28;

import "../lib/forge-std/src/Test.sol";
//import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
//import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";

contract TestStakingApp is Test {
    
    StakingToken stakingToken;
    StakingApp stakingApp; // initialize smart contract

    // StakingToken Parameters
    string name = "BB Token";
    string symbol = "BBT";

    // StakingApp Parameters
    address owner = vm.addr(1);
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
}