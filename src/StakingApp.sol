// SPDX-Identifier: MIT

// forge install openzeppelin/openzeppelin-contracts
pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// Staking token address
// Admin access control

contract StakingApp is Ownable {

    // Variables
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPerPeriod;
    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public depositTimestamp;

    // Events
    event newStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_);
    event EtherSent(uint256 amount_);

    // Constructor
    constructor(address stakingToken_, address owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_, uint256 rewardPerPeriod_) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    // Functions

    // External

    // Deposit

    function depositTokens(uint256 depositAmount_) external {
        require(depositAmount_ == fixedStakingAmount, "Wrong amount");
        require(userBalance[msg.sender] == 0, "Already Deposited Tokens");
        
        IERC20(stakingToken).transferFrom(msg.sender, address(this),depositAmount_);
        userBalance[msg.sender] += depositAmount_;
        depositTimestamp[msg.sender] = block.timestamp;

        emit DepositTokens(msg.sender, depositAmount_);
    }

    // Withdraw
    function withdrawTokens() external {

        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, userBalance_);

        emit WithdrawTokens(msg.sender, userBalance_);
    }

    // Claim Rewards
    function claimRewards() external {
        // Checks
        require(userBalance[msg.sender] == fixedStakingAmount, "User is not staking.");

        uint256 elapsedPeriod = block.timestamp - depositTimestamp[msg.sender];
        require(elapsedPeriod >= stakingPeriod, "Wait to claim rewards.");
        
        // Effects
        depositTimestamp[msg.sender] = block.timestamp; // avoid calling the function in loop.

        // Interact
        (bool success,) = msg.sender.call{value: rewardPerPeriod}("");
        require(success, "Transfer failed");
    }

    // function feedContract() external payable onlyOwner {} // not a best practice -> admin can stop feeding the contract and run out of funds.
    receive() external payable onlyOwner {
        emit EtherSent(msg.value);
    }
        
    function updateStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;

        emit newStakingPeriod(newStakingPeriod_);
    }
}