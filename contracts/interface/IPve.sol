// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPve {
    // 事件
    event PlunderBattleReport(
        address indexed attacker,
        uint256 attackId,
        uint256 targetId,
        bool success,
        bool first,
        uint256[] damage
    );
    // event Capture(address indexed attacker,uint timestamp,bool indexed isCapture,uint indexed tokenId);
    event RewardDrop(
        address indexed player,
        uint256 ElementType,
        uint256 amount
    );
    event BattleOnevOne(
        address indexed attacker,
        bool success,
        uint256[] amount,
        uint256 captureSelfId,
        uint256 captureEnemieId
    );
    event BattleThreevThree(
        address indexed attacker,
        bool success,
        uint256[] amount,
        uint256[] captureSelfIds,
        uint256[] captureEnemieIds
    );

    //刷新对应用户1v1的当前敌人
    function refresh1V1() external;

    //刷新对应用户3v3的当前敌人
    function refresh3V3() external;

    //获取1v1的敌人
    function get1V1Enemies(address user)
        external
        view
        returns (uint256[] memory enemies, uint256[3] memory defeat);

    //获取3v3的敌人
    function get3V3Enemies(address user)
        external
        view
        returns (uint256[] memory enemies, uint256[3] memory defeat);

    //1v1决斗
    function battle1V1(uint256 tokenId, uint256 targetId) external;

    //3v3决斗
    function battle3V3(uint256[] memory tokenId, uint256 index) external;

    //获取对应用户的战斗奖励 -- 资源
    function pendingReward(address user)
        external
        view
        returns (uint256[6] memory reward);

    //提取用户资源
    function takeReward() external;

    // 查询用户1v1 此次刷新是否免费
    function refresh1v1ForFree(address player) external view returns (bool);

    // 查询用户3v3 此次刷新是否免费
    function refresh3v3ForFree(address player) external view returns (bool);
}
