// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./PrimalPveBase.sol";
import "../lib/struct/LibUintSet.sol";

contract PrimalPve is PrimalPveBase{
    using LibUintSet for LibUintSet.UintSet;
   
    constructor(
        IERC721 primalNft_,
        IPrimalData primalRepo_
        ) {
        primalNft = primalNft_;
        primalRepo = primalRepo_;
    }
    // 1v1 refresh
    function refresh1V1() public override {
        // 野区 野怪数量检查
        if(!refresh1v1ForFree(msg.sender)){
            _payForRefresh();
        }
        _refresh(msg.sender,3);
    }

    // 3v3 refresh
    function refresh3V3() public override {
        if(!refresh3v3ForFree(msg.sender)){
            _payForRefresh();
        }
        _refresh(msg.sender,9);
    }

    // 1v1 attack
    function battle1V1(uint256 playerHeroId,uint256 creepId) external override {
        // isApproveforAll to this contract
        require(primalNft.isApprovedForAll(msg.sender,address(this)),"not approve");
        // 对战列表是否为空
        require(!player1v1RefreshListEmpty(msg.sender),"creeps list empty");
        // 判断所选英雄是否属于 交易发起者
        require(primalNft.ownerOf(playerHeroId)==msg.sender && primalNft.ownerOf(creepId)==address(this),"not owner");
        // 野怪是否在对战列表内
        (bool isExist ,uint index) = current1v1CreepsList[msg.sender].atPosition(creepId);
        // 判断敌人是否已经被打败
        require(isExist  && player1v1Defeat[msg.sender][index] != 1,"id not valid or already defeat this creep");
        (bool success,uint256[] memory amount,uint256 captureSelfId,uint256 captureEnemieId) = _battle1v1(playerHeroId,creepId);
        emit BattleOnevOne(msg.sender,success,amount,captureSelfId,captureEnemieId);
    }

    // 3v3 attack
    function battle3V3(uint256[] memory playerHeroIds,uint256 group) external override{
        require(playerHeroIds.length == 3 ,"heros length not valid");
            // isApproveforAll to this contract
        require(primalNft.isApprovedForAll(msg.sender,address(this)),"is not approve");
        // // check  creeps list is empty
        require(!player3v3RefreshListEmpty(msg.sender),"creeps list empty");
        require(group < 3,"index out bounds");
        uint[] memory creeps = get3V3EnemiesByGroup(msg.sender,group);
        for(uint256 i=0;i<3;i++){
            require(primalNft.ownerOf(playerHeroIds[i])==msg.sender && primalNft.ownerOf(creeps[i])==address(this),"not owner");
        }
        require(player3v3Defeat[msg.sender][group] != 1,"already defeat this creeps");
        (bool success,uint256[] memory amount,uint256[] memory captureSelfIds,uint256[] memory captureEnemieIds) =  _battle3v3(playerHeroIds,group);
        emit BattleThreevThree(msg.sender,success,amount,captureSelfIds,captureEnemieIds);
    }

}
