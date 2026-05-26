// SPDX-Identifier: MIT

// forge install openzeppelin/openzeppelin-contracts
pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// Staking token address
// Admin access control

contract stakingApp is Ownable {

    // Variables
    address public stakingToken;

    // Constructor
    constructor(address stakingToken_, address owner_) Ownable(owner_) {
        stakingToken = stakingToken_;
        // owner = owner_;
    }

    // Functions
}