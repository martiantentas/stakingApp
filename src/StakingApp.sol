// SPDX-Identifier: MIT

pragma solidity 0.8.28;

// Staking token address
// Admin access control

contract stakingApp {

    // Variables
    address public stakingToken;
    address public owner;

    // Constructor
    constructor(address stakingToken_, address owner_) {
        stakingToken = stakingToken_;
        // owner = owner_;
    }

    // Functions
}