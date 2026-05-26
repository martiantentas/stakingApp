// SPDX-License: MIT

pragma solidity 0.8.28;

import "../lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../src/StakingToken.sol";

contract TestStakingToken is Test {
    
    StakingToken stakingToken; // initialize smart contract
    string name = "BB Token";
    string symbol = "BBT";
    address public user = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name, symbol);
    }

    function testStakingTokenMint(uint256 amount_) public {
        vm.startPrank(user);
        // get balance before minting
        uint256 blanceBefore_ = IERC20(address(stakingToken)).balanceOf(user);

        // mint tokens
        stakingToken.mint(amount_);

        // get balance after minting
        uint256 blanceAfter_ = IERC20(address(stakingToken)).balanceOf(user);
        assert(blanceAfter_ - blanceBefore_ == amount_);

        vm.stopPrank();
    }
}