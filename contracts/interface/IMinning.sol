// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IMining  {

    event SetManager(address indexed oldManager, address indexed newManager);
    //质押事件 用户质押NFT的tokenId与skillId对应的池子里，amount为每小时的产量
    event Stake(address indexed user, uint256 indexed tokenId,uint skillId,uint amount);
    event Unstake(address indexed user, uint256 indexed tokenId);
    event PlunderBattleReport(address indexed attacker, address indexed defender,uint attackId,uint targetId,uint timeStamp,bool success,bool first,uint[] damage);

    event PlunderReward(address indexed attacker, address indexed defender,uint attackId,uint targetId,uint timeStamp,uint[] reward);
    //放到某个池子里挖矿
    function stake(uint tokenId,uint poolType) external;

    //取消某个池子的挖矿
    function unStake(uint tokenId,uint poolType) external;

    //掠夺某个矿池
    function plunder(uint tokenId,uint poolType) external;

    //获取对应用户的挖矿奖励
    function pendingReward(address user) external view returns (uint256[] memory reward);

    //返回某个矿池的基础属性 ==》 yield 基础产量 amount 在挖人数
    function getPoolAttr(uint poolType) external view returns (uint yield, uint amount);

    //提取用户资源
    function takeReward() external;

    //返回用户在某个矿池下的id
    function getAllStakeIds(address user,uint poolType) external view returns (uint[] memory);
}

