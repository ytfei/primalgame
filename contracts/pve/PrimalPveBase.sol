// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/LibRandom.sol";
import "../lib/Libdatetime.sol";
import "../lib/LibBattle.sol";
import "../lib/LibPrimalMetaData.sol";
import "../interface/IPrimalData.sol";
import "../lib/struct/LibUintSet.sol";
import "../interface/IPve.sol";

abstract contract PrimalPveBase is Ownable, IERC721Receiver, IPve {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using LibUintSet for LibUintSet.UintSet;
    using SafeERC20 for IERC20;

    Counters.Counter public randNonce;

    IERC721 primalNft;
    IPrimalData primalRepo; // primal matedata contract
    //每次刷新的费用
    uint256 public refreshFee = 1 ether;
    //所有的野怪集合
    LibUintSet.UintSet totalCreeps;
    //所有的未刷新给用户的集合
    LibUintSet.UintSet totalUnRefreshCreeps;
    //用户1v1野怪集合
    mapping(address => LibUintSet.UintSet) current1v1CreepsList;
    //用户3v3野怪集合
    mapping(address => LibUintSet.UintSet) current3v3CreepsList;
    //上一次刷新时间
    mapping(address => uint256) _last1v1RefreshTime; // second
    mapping(address => uint256) _last3v3RefreshTime; // second

    // defeat 当前组是否被击败 0代表被击败 1代表已击败
    mapping(address => uint256[3]) player1v1Defeat;
    mapping(address => uint256[3]) player3v3Defeat;

    mapping(address => uint256[6]) playerResource;
    // reward output rules
    uint256[5] baseReward = [1, 3, 9, 27, 81];

    IERC20[6] public elementAddress = [
        LibPrimalMetaData.WIND,
        LibPrimalMetaData.LIFE,
        LibPrimalMetaData.WATER,
        LibPrimalMetaData.FIRE,
        LibPrimalMetaData.EARTH,
        LibPrimalMetaData.SOURCE
    ];

    // check refresh for free 判断用户是否能免费刷新1v1
    function refresh1v1ForFree(address player)
        public
        view
        override
        returns (bool)
    {
        // 判断用户敌人列表是否为空，空可以免费刷新
        if (player1v1RefreshListEmpty(player)) {
            return true;
        }
        // 判断是否到24点免费刷新时间
        return _currentIsAvaliable(_last1v1RefreshTime[player]);
    }

    // 判断用户是否能免费刷新3v3
    function refresh3v3ForFree(address player)
        public
        view
        override
        returns (bool)
    {
        // 判断是否是空
        if (player3v3RefreshListEmpty(player)) {
            return true;
        }
        return _currentIsAvaliable(_last3v3RefreshTime[player]);
    }

    // get player enemies
    function get1V1Enemies(address player)
        public
        view
        override
        returns (uint256[] memory enemies, uint256[3] memory defeat)
    {
        enemies = current1v1CreepsList[player].getAll();
        defeat = player1v1Defeat[player];
    }

    function get3V3Enemies(address player)
        public
        view
        override
        returns (uint256[] memory enemies, uint256[3] memory defeat)
    {
        enemies = current3v3CreepsList[player].getAll();
        defeat = player1v1Defeat[player];
    }

    // query reward not withdraw  获取用户的未提取资源
    function pendingReward(address player)
        public
        view
        override
        returns (uint256[6] memory)
    {
        return playerResource[player];
    }

    function takeReward() public override {
        for (uint256 i = 0; i < 6; i++) {
            uint256 amount = playerResource[msg.sender][i];
            if (amount == 0) {
                continue;
            }
            // reset to zero
            playerResource[msg.sender][i] = 0;
            elementAddress[i].safeTransfer(msg.sender, amount * 1 ether);
        }
    }

    // 刷新野怪列表
    function _refresh(address player, uint256 length) internal {
        uint256[] memory playerCreeps = getPlayerCreepsList(player, length);
        //如果长度为0 代表的是第一次刷新
        if (playerCreeps.length == 0) {
            _obtainCreeps(player, length);
        } else {
            _refresh(player, length, playerCreeps);
        }
        //击败结果重置
        if (length > 3) {
            player3v3Defeat[player] = [0, 0, 0];
            _last3v3RefreshTime[player] = block.timestamp;
        } else {
            player1v1Defeat[player] = [0, 0, 0];
            _last1v1RefreshTime[player] = block.timestamp;
        }
    }

    //不是第一次刷新野怪
    function _refresh(
        address player,
        uint256 length,
        uint256[] memory playerCreeps
    ) private {
        //先把用户之前的野怪id放进未刷新的野怪列表中
        require(totalUnRefreshCreeps.getSize() > 0, "creeps not enough");
        for (uint256 i = 0; i < playerCreeps.length; i++) {
            totalUnRefreshCreeps.add(playerCreeps[i]);
        }
        uint256[] memory refreshCreeps = new uint256[](playerCreeps.length);
        for (uint256 i = 0; i < playerCreeps.length; i++) {
            //随机一个tokenId
            //随机一个tokenId
            refreshCreeps[i] = _getTokenIdFromUnRefreshCreeps(i);
            //替换掉对应用户位置的tokenId
        }
        if (length > 3) current3v3CreepsList[player].replaceAll(refreshCreeps);
        else current1v1CreepsList[player].replaceAll(refreshCreeps);
    }

    // 第一次刷新野怪列表
    function _obtainCreeps(address player, uint256 length) private {
        // 判断当前可用的野怪池数量
        require(totalUnRefreshCreeps.getSize() >= length, "creeps not enough");
        for (uint256 i = 0; i < length; i++) {
            //随机一个tokenId
            uint256 tokenId = _getTokenIdFromUnRefreshCreeps(i);
            //替换掉对应用户位置的tokenId
            if (length > 3) current3v3CreepsList[player].add(tokenId);
            else current1v1CreepsList[player].add(tokenId);
        }
    }

    function _getTokenIdFromUnRefreshCreeps(uint256 rand)
        private
        returns (uint256 tokenId)
    {
        //随机一个tokenId
        uint256 randomIndex = LibRandom.randMod(
            totalUnRefreshCreeps.getSize(),
            rand
        );
        tokenId = totalUnRefreshCreeps.getByIndex(randomIndex);
        //从未刷新给用户的列表中移除
        totalUnRefreshCreeps.remove(tokenId);
    }

    function player1v1RefreshListEmpty(address player)
        internal
        view
        returns (bool)
    {
        return current1v1CreepsList[player].getSize() == 0;
    }

    function player3v3RefreshListEmpty(address player)
        internal
        view
        returns (bool)
    {
        return current3v3CreepsList[player].getSize() == 0;
    }

    //付钱刷新
    function _payForRefresh() internal {
        // require(LibPrimalMetaData.PRIMALCOIN.allowance(player,address(this))>=refreshFee,"first step is approve some balance for pve contract");
        require(
            LibPrimalMetaData.PRIMALCOIN.transferFrom(
                msg.sender,
                address(this),
                refreshFee
            ),
            "pay for refresh faild"
        );
    }

    //设置刷新的费用
    function setRefreshFee(uint256 _fee) public onlyOwner {
        refreshFee = _fee;
    }

    // 设置repo仓库
    function setRepodAddress(address repo_) public onlyOwner {
        primalRepo = IPrimalData(repo_);
    }

    //判断是否可以免费刷新
    function _currentIsAvaliable(uint256 lastTime) private view returns (bool) {
        (uint256 year, uint256 month, uint256 day) = TimeLibrary
            .timestampToDate(lastTime);
        (
            uint256 currentyear,
            uint256 currentmonth,
            uint256 currentday
        ) = TimeLibrary.timestampToDate(block.timestamp);
        if (currentyear >= year && currentmonth >= month && currentday > day) {
            return true;
        }
        return false;
    }

    function getPlayerCreepsList(address player, uint256 length)
        public
        view
        returns (uint256[] memory)
    {
        if (length > 3) return current3v3CreepsList[player].getAll();
        return current1v1CreepsList[player].getAll();
    }

    function _battle1v1(uint256 playerHeroId, uint256 creepId)
        internal
        returns (
            bool success,
            uint256[] memory amount,
            uint256 captureSelfId,
            uint256 captureEnemieId
        )
    {
        amount = new uint256[](6);
        success = battle(playerHeroId, creepId);
        if (success) {
            //胜利的掉落
            (uint256 eleTyle, uint256 _amount) = rewardDrop(
                msg.sender,
                creepId
            );
            amount[eleTyle] = _amount;
            //记录击败状态
            player1v1Defeat[msg.sender][
                current1v1CreepsList[msg.sender].indexes[creepId] - 1
            ] = 1;
        }
        (captureSelfId, captureEnemieId) = capture(
            playerHeroId,
            creepId,
            success
        );
    }

    function battle(uint256 playerHeroId, uint256 creepId)
        internal
        returns (bool)
    {
        (bool success, bool first, uint256[] memory damages) = LibBattle.battle(
            playerHeroId,
            creepId,
            primalRepo
        );
        //撕逼输的那个扣好感度
        primalRepo.consumePrimalStamina(success ? creepId : playerHeroId);
        emit PlunderBattleReport(
            primalNft.ownerOf(playerHeroId),
            playerHeroId,
            creepId,
            success,
            first,
            damages
        );
        return success;
    }

    function capture(
        uint256 playerHeroId,
        uint256 creepId,
        bool success
    ) internal returns (uint256 captureSelfId, uint256 captureEnemieId) {
        //好感度掉为0后，有一定概率被俘获
        if (
            primalRepo.getPriamlStamina(playerHeroId) == 0 ||
            primalRepo.getPriamlStamina(creepId) == 0
        ) {
            //判断是否可被俘获 todo 概率每10天减少10%
            bool canCapture = LibRandom.randMod(100, randNonce.current()) < 10;
            randNonce.increment();
            if (
                canCapture &&
                success &&
                primalRepo.getPriamlStamina(creepId) == 0
            ) {
                captureEnemieId = creepId;
                //干架的抓走野怪
                totalCreeps.remove(creepId);
                //TODO: 这里的野怪已经不在未使用的列表中
                totalUnRefreshCreeps.remove(creepId);
                //转给用户
                primalNft.safeTransferFrom(address(this), msg.sender, creepId);
                // emit Capture(msg.sender,block.timestamp,true,creepId);
            } else if (
                canCapture &&
                !success &&
                primalRepo.getPriamlStamina(playerHeroId) == 0
            ) {
                //打架的被抓走了
                captureSelfId = playerHeroId;
                primalNft.safeTransferFrom(
                    msg.sender,
                    address(this),
                    playerHeroId
                );
                // emit Capture(msg.sender,block.timestamp,false,playerHeroId);
            }
        }
    }

    function _battle3v3(uint256[] memory playerHeroIds, uint256 creepsIndex)
        internal
        returns (
            bool success,
            uint256[] memory amount,
            uint256[] memory captureSelfIds,
            uint256[] memory captureEnemieIds
        )
    {
        amount = new uint256[](6);
        captureSelfIds = new uint256[](3);
        captureEnemieIds = new uint256[](3);
        //获取第几组敌人
        uint256[] memory enemies = get3V3EnemiesByGroup(
            msg.sender,
            creepsIndex
        );
        //记录胜利次数
        uint256 successAmount = 0;
        for (uint256 i = 0; i < playerHeroIds.length; i++) {
            bool roundWin = battle(playerHeroIds[i], enemies[i]);
            if (roundWin) successAmount.add(1);
            //产生捕获操作
            (uint256 captureSelfId, uint256 captureEnemieId) = capture(
                playerHeroIds[i],
                enemies[i],
                roundWin
            );
            captureSelfIds[i] = captureSelfId;
            captureEnemieIds[i] = captureEnemieId;
        }
        //需要胜利两次以上
        success = successAmount > 1;
        //战利品
        if (success) {
            for (uint256 i = 0; i < 3; i++) {
                //战利品
                (uint256 eleTyle, uint256 _amount) = rewardDrop(
                    msg.sender,
                    enemies[i]
                );
                amount[eleTyle] = amount[eleTyle].add(_amount);
            }
            //记录击败状态
            player3v3Defeat[msg.sender][creepsIndex] = 1;
        }
    }

    // // get player enemies
    function get3V3EnemiesByGroup(address player, uint256 group)
        internal
        view
        returns (uint256[] memory enemies)
    {
        enemies = new uint256[](3);
        LibUintSet.UintSet storage allEnemies = current3v3CreepsList[player];
        for (uint256 i = 0; i < enemies.length; i++) {
            enemies[i] = allEnemies.getByIndex(group.mul(3).add(i));
        }
    }

    //奖品的掉落
    function rewardDrop(address player, uint256 creepId)
        internal
        returns (uint256 randomType, uint256 amount)
    {
        randomType = LibRandom.randMod(5, randNonce.current());
        randNonce.increment();
        uint8 rarity = primalRepo.getPrimalRarity(creepId);
        uint256 baseAmount = baseReward[rarity];
        // some element balance is drop.
        amount = baseAmount * 30;
        playerResource[player][randomType] = playerResource[player][randomType]
            .add(amount);
        emit RewardDrop(player, randomType, baseAmount * 30);
    }

    function safeTransferBackToNft(uint256 tokenId, address to)
        public
        onlyOwner
    {
        require(totalUnRefreshCreeps.contains(tokenId), "not exist");
        require(
            IERC721(primalNft).ownerOf(tokenId) == address(this),
            "not owner"
        );
        totalUnRefreshCreeps.remove(tokenId);
        totalCreeps.remove(tokenId);
        primalNft.safeTransferFrom(address(this), to, tokenId);
    }

    function transferBackToNft(uint256 tokenId, address to) public onlyOwner {
        require(totalCreeps.contains(tokenId), "not exist");
        require(
            IERC721(primalNft).ownerOf(tokenId) == address(this),
            "Not owner"
        );
        totalUnRefreshCreeps.remove(tokenId);
        totalCreeps.remove(tokenId);
        primalNft.safeTransferFrom(address(this), to, tokenId);
    }

    function claimPayment(address token, address payee) external onlyOwner {
        require(payee != address(0), "zero address");
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "not enough balance");
        IERC20(token).transfer(payee, amount);
    }

    // function testAll() public view returns (uint[] memory) {
    //     return totalCreeps.getAll();
    // }

    // function testAllUnRefresh() public view returns (uint[] memory) {
    //     return totalUnRefreshCreeps.getAll();
    // }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (msg.sender == address(primalNft)) {
            totalCreeps.add(tokenId);
            totalUnRefreshCreeps.add(tokenId);
        }
        return this.onERC721Received.selector;
    }
}
