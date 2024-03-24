// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ReentrancyGuard {

    using SafeMath for uint256;
    IERC20 public staking_Token;
    IERC20 public reward_Token;

    uint256 public constant RewardRate=10;
    uint256 private totalSatkedTokens;
    uint256 public rewardPerTokenStaked;
    uint256 public lastUpdateTime;

    mapping(address=>uint256) public stakedBalance;
    mapping(address=>uint256) public rewards;
    mapping(address=>uint256) public userRewardPerTokenPaid;

    event Staked(address indexed user,uint256 indexed amount);
    event Withdrawn(address indexed user,uint256 indexed amount);
    event RewardClaimed(address indexed user,uint256 indexed amount);

    constructor(address stakingToken, address rewardToken){
        staking_Token = IERC20(stakingToken);
        reward_Token = IERC20(rewardToken);
    }

    modifier updateReward(address account){
        rewardPerTokenStaked = rewardPerToken();
        lastUpdateTime=block.timestamp;
        rewards[account]=earned(account);
        userRewardPerTokenPaid[account]=rewardPerTokenStaked;
        _;
    }

    function rewardPerToken() public view returns(uint256){
        if(totalSatkedTokens==0){
            return rewardPerTokenStaked;
        }
        uint256 totalTime = block.timestamp - lastUpdateTime ;
        uint256 totalRewards = RewardRate*totalTime;
        return rewardPerTokenStaked+(totalRewards/totalSatkedTokens); //here:sum=sum+n
    }

    function earned(address account) public view returns(uint256){
        return (stakedBalance[account])*(rewardPerToken()-userRewardPerTokenPaid[account]);
    }

    function stake(uint256 amount) external nonReentrant updateReward(msg.sender){
        require(amount>0,"Amount must be greater then zero");
        totalSatkedTokens+=amount;
        stakedBalance[msg.sender]+=amount;
        emit Staked(msg.sender,amount);

        bool success = staking_Token.transferFrom(msg.sender,address(this),amount);
        require(success,"Transfer Failed");
    }

    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender){
        require(amount>0,"Amount must be greater then zero");
        totalSatkedTokens-=amount;
        stakedBalance[msg.sender]-=amount;
        emit Withdrawn(msg.sender,amount);

        bool success = staking_Token.transfer(msg.sender,amount);
        require(success,"Transfer Failed");
    }

    function getReward() external nonReentrant updateReward(msg.sender){
        uint256 reward = rewards[msg.sender];
        require(reward>0,"No reward to claim");
        rewards[msg.sender]=0;
        emit RewardClaimed(msg.sender,reward);

        bool success = reward_Token.transferFrom(msg.sender,address(this),reward);
        require(success,"Transfer Failed");
    }


}

//staketime = 1711308561