// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract RewardPool  {
    using SafeMath for uint256;

    address private _manager;

    function manager() public view returns (address) { return _manager; }

    modifier onlyManager() {
        require(msg.sender == _manager, "only manager");
        _;
    }

    struct UserInfo {
        //User stake computing power
        uint256 stake;
        //The amount of the award
        uint256 rewardBalance;
        //The amount owed for the previous block, the calculation needs to be subtracted
        uint256 rewardDebt;
    }

    mapping (address => UserInfo) private _userInfo;

    //Total Stake Counting Power
    uint256 public totalStake;
    //Rewards per block
    uint256 public rewardPerBlock;
    //reward start block
    uint256 public rewardStartBlock;
    //last reward block
    uint256 public lastRewardBlock;
    //Factor for block calculation rewards
    uint256 private _accRewardPerShare;
   
    
    event AddStake(address indexed user, uint256 indexed amount);
    event SubStake(address indexed user, uint256 indexed amount);
    event TakeReward(address indexed user, uint256 indexed amount);
   
    constructor(
        address _stakeContract,
        uint256 _rewardPerBlock,
        uint256 _rewardStartBlock
    )  {
        require(_stakeContract != address(0), "ctor: zero stake contract");
        require(_rewardPerBlock > 1e6, "ctor: reward per block is too small");
        _manager = _stakeContract;
        rewardPerBlock = _rewardPerBlock;
        rewardStartBlock = _rewardStartBlock;
        lastRewardBlock = block.number > rewardStartBlock ? block.number : rewardStartBlock;
    }

    
    function userInfo(address _user) public view returns (uint256 stakeAmount) {
        UserInfo storage user = _userInfo[_user];
        stakeAmount = user.stake;
    }

    
    function setRewardPerBlock(uint256 _rewardPerBlock) public onlyManager {
        updatePool();
        rewardPerBlock = _rewardPerBlock;
    }

    function accRewardPerShare() public view returns (uint256) {
        //If the current block is smaller than the last rewarded block. Or the total stake is 0, or the rewardPerBlock is 0
        if (block.number <= lastRewardBlock || totalStake == 0 || rewardPerBlock == 0 ) {
            return _accRewardPerShare;
        }
        uint256 multiplier = block.number.sub(lastRewardBlock);
        uint256 tokenReward = multiplier.mul(rewardPerBlock);
        return _accRewardPerShare.add(tokenReward.mul(1e12));
    }

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = _userInfo[_user];
        uint256 reward = user.stake.mul(accRewardPerShare()).div(1e12);
        uint256 pending = 0;
        if (reward > user.rewardDebt) {
            pending = reward.sub(user.rewardDebt);
        }
        return user.rewardBalance.add(pending);
    }

    function updatePool() public {
        if (block.number > lastRewardBlock) {
            _accRewardPerShare = accRewardPerShare();
            lastRewardBlock = block.number;
        }
    }
    
    
    function _farm(address _user) internal {
        updatePool();
        UserInfo storage user = _userInfo[_user];
        if (user.stake > 0) {
            uint256 reward = user.stake.mul(_accRewardPerShare).div(1e12);
            if (reward > user.rewardDebt) {
                uint256 pending = reward.sub(user.rewardDebt);
                user.rewardBalance = user.rewardBalance.add(pending);
            }
        }
    }

    function subReward(address _user,uint rate) public onlyManager returns(uint256 plunderReward) {
         _farm(_user);
        UserInfo storage user = _userInfo[_user];
        plunderReward = user.rewardBalance.mul(rate).div(100);
        user.rewardBalance = user.rewardBalance.sub(plunderReward);
        user.rewardDebt = user.stake.mul(_accRewardPerShare).div(1e12);
        emit TakeReward(_user, plunderReward);
    }

    function takeReward(address _user) public onlyManager returns (uint256 reward) {
        _farm(_user);
        UserInfo storage user = _userInfo[_user];
        reward = user.rewardBalance;
        user.rewardBalance = 0;
        user.rewardDebt = user.stake.mul(_accRewardPerShare).div(1e12);
        emit TakeReward(_user, reward);
    }

    function addStake(address _user, uint256 _amount) public onlyManager {
        require(_amount > 0, "zero amount");
        _farm(_user);
        UserInfo storage user = _userInfo[_user];
        totalStake = totalStake.add(1);
        user.stake = user.stake.add(_amount);
        user.rewardDebt = user.stake.mul(_accRewardPerShare).div(1e12);
        emit AddStake(_user, _amount);
    }

    function subStake(address _user, uint256 _amount) public onlyManager {
        require(_amount > 0, "zero amount");
        _farm(_user);
        UserInfo storage user = _userInfo[_user];
        totalStake = totalStake.sub(1);
        user.stake = user.stake.sub(_amount);
        user.rewardDebt = user.stake.mul(_accRewardPerShare).div(1e12);
        emit SubStake(_user, _amount);
    }

}