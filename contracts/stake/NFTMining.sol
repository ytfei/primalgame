// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./RewardPool.sol";
import "../interface/IPrimalData.sol";
import "../interface/IMinning.sol";
import "../lib/LibPrimalMetaData.sol";
import "../lib/struct/LibUintSet.sol";
import "../lib/LibRandom.sol";
import "../lib/LibBattle.sol";

contract NFTMining is IMining, IERC721Receiver, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using LibUintSet for LibUintSet.UintSet;
    using Counters for Counters.Counter;

    Counters.Counter public randNonce;

    address public manager;

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    modifier canStake(uint256 tokenId, uint256 poolType) {
        // require(poolType <= uint(LibPrimalMetaData.PoolType.Source),"This pool type not support");
        require(poolType < rewardPool.length, "This pool type not support");
        uint256 exist = primalRepo.getPrimalSingleSkill(tokenId, poolType);
        require(exist == 1, "This nft can't mining here or not mining here");
        _;
    }

    // Mapping from nft token ID to owner address
    mapping(uint256 => address) private _stakes;

    // 记录对应用户某个矿池下的英雄
    mapping(address => mapping(uint256 => LibUintSet.UintSet))
        private _minerStakes;

    //记录这个用户掠夺的收益
    mapping(address => mapping(uint256 => uint256)) private _plunderAmounts;
    // 记录矿池下所有的英雄
    mapping(uint256 => LibUintSet.UintSet) private _poolStakes;

    //6个矿池
    RewardPool[] public rewardPool;

    //品质等级挖矿速率
    uint256[5] private _baseMining = [1, 3, 9, 27, 81];
    uint256[5] private _basePlunerRate = [50, 60, 70, 80, 90];
    //基础产量为每小时10个
    uint256 private _baseProduct = 10 ether;
    //每3秒一个区块
    uint256 private _baseBlockTime = 3;
    //初始时候有6个ERC20的token地址
    IERC20[] public tokens = [
        LibPrimalMetaData.WIND,
        LibPrimalMetaData.LIFE,
        LibPrimalMetaData.WATER,
        LibPrimalMetaData.FIRE,
        LibPrimalMetaData.EARTH,
        LibPrimalMetaData.SOURCE
    ];

    //质押的NFT地址
    IERC721 public nftAddress; // Desposit nft address

    //数据仓库地址
    IPrimalData public primalRepo;

    constructor(address _nftAddress, IPrimalData _primalRepo) {
        nftAddress = IERC721(_nftAddress);
        primalRepo = _primalRepo;
        manager = msg.sender;

        // for (uint256 i = 0; i < 6; i++) {
        //     RewardPool pool = new RewardPool(
        //         address(this),
        //         _getRewardPerBlock(),
        //         block.number
        //     );
        //     rewardPool.push(RewardPool(pool));
        // }

        emit SetManager(address(0), manager);
    }

    // TODO: set reward pool from outside
    // function addRewardPools(address pool) public onlyOwner {
    //     //初始的时候有6个矿池
    //     // for (uint256 i = 0; i < 6; i++) {
    //     //     RewardPool pool = new RewardPool(
    //     //         address(this),
    //     //         _getRewardPerBlock(),
    //     //         block.number
    //     //     );
    //     // }
    //     // rewardPool.push(RewardPool(pool));
    // }

    //放到某个池子里挖矿
    function stake(uint256 tokenId, uint256 poolType)
        external
        override
        canStake(tokenId, poolType)
    {
        require(
            nftAddress.ownerOf(tokenId) == msg.sender,
            "60003:This nft not belong to you"
        );
        uint256 stakeAmount = _getStakeAmount(tokenId);
        //将NFT转到当前合约地址下
        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        //添加进奖励池
        rewardPool[poolType].addStake(msg.sender, stakeAmount);
        //记录token信息
        _addTokenToMiningPool(tokenId, poolType);
        emit Stake(msg.sender, tokenId, poolType, stakeAmount * _baseProduct);
    }

    //取消某个池子的挖矿
    function unStake(uint256 tokenId, uint256 poolType)
        external
        override
        canStake(tokenId, poolType)
    {
        require(
            _stakes[tokenId] == msg.sender,
            "60005:This NFT is not stake by you"
        );
        uint256 stakeAmount = _getStakeAmount(tokenId);
        _removeTokenFromMiningPool(tokenId, poolType);
        //减少质押数量
        rewardPool[poolType].subStake(msg.sender, stakeAmount);
        //转给用户
        nftAddress.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Unstake(msg.sender, stakeAmount);
    }

    function getAllStakeIds(address user, uint256 poolType)
        public
        view
        override
        returns (uint256[] memory)
    {
        LibUintSet.UintSet storage minerStakeSet = _minerStakes[user][poolType];
        return minerStakeSet.getAll();
    }

    function getPoolStake(uint256 poolType)
        public
        view
        returns (uint256[] memory)
    {
        LibUintSet.UintSet storage poolStakeSet = _poolStakes[poolType];
        return poolStakeSet.getAll();
    }

    //掠夺某个矿池
    function plunder(uint256 tokenId, uint256 poolType) external override {
        //判断这个NFT是否归属于用户
        require(
            nftAddress.ownerOf(tokenId) == msg.sender,
            "60003:This nft not belong to you"
        );
        //判断用户是否都授权NFT到这个合约了
        require(
            nftAddress.isApprovedForAll(msg.sender, address(this)),
            "Not approve to this contract"
        );
        //判断这个NFT是否具有掠夺技能
        require(
            primalRepo.getPrimalSingleSkill(
                tokenId,
                uint256(LibPrimalMetaData.SkillType.Plunder)
            ) == 1,
            "This nft can't mining here or not mining here"
        );
        uint256 targetId = _getRandIdFromPool(poolType);
        //两个NFT撕逼
        (bool success, bool first, uint256[] memory damages) = LibBattle.battle(
            tokenId,
            targetId,
            primalRepo
        );
        emit PlunderBattleReport(
            msg.sender,
            _stakes[targetId],
            tokenId,
            targetId,
            block.timestamp,
            success,
            first,
            damages
        );
        //撕逼输的那个扣好感度
        primalRepo.consumePrimalStamina(success ? targetId : tokenId);
        if (success) {
            uint256 stakeAmount = _getStakeAmount(targetId);
            uint256 plunderReward = rewardPool[poolType].subReward(
                _stakes[targetId],
                _basePlunerRate[primalRepo.getPrimalRarity(tokenId)],
                stakeAmount
            );
            //todo 记录用户对应的资源数
            _plunderAmounts[msg.sender][poolType] = _plunderAmounts[msg.sender][
                poolType
            ].add(plunderReward);
            //event事件
            uint256[] memory reward = new uint256[](rewardPool.length);
            reward[poolType] = plunderReward;
            emit PlunderReward(
                msg.sender,
                _stakes[targetId],
                tokenId,
                targetId,
                block.timestamp,
                reward
            );
        }
        //好感度掉为0后，有一定概率被俘获
        if (
            primalRepo.getPriamlStamina(tokenId) == 0 ||
            primalRepo.getPriamlStamina(targetId) == 0
        ) {
            //判断是否可被俘获
            bool capture = LibRandom.randMod(100, randNonce.current()) < 10;
            randNonce.increment();
            if (
                capture && success && primalRepo.getPriamlStamina(targetId) == 0
            ) {
                uint256 stakeAmount = _getStakeAmount(targetId);
                //减少质押数量
                rewardPool[poolType].subStake(
                    nftAddress.ownerOf(targetId),
                    stakeAmount
                );
                //干架的抓走采矿的
                _removeTokenFromMiningPool(targetId, poolType);
                //转给用户
                nftAddress.safeTransferFrom(
                    address(this),
                    msg.sender,
                    targetId
                );
            } else if (
                capture && !success && primalRepo.getPriamlStamina(tokenId) == 0
            ) {
                //打架的被抓走了
                nftAddress.safeTransferFrom(
                    msg.sender,
                    _stakes[targetId],
                    tokenId
                );
            }
        }
    }

    //获取对应用户的挖矿奖励
    function pendingReward(address user)
        external
        view
        override
        returns (uint256[] memory reward)
    {
        reward = new uint256[](rewardPool.length);
        for (uint256 i = 0; i < rewardPool.length; i++) {
            reward[i] = rewardPool[i].pendingReward(user).add(
                _plunderAmounts[user][i]
            );
        }
    }

    //返回某个矿池的基础属性 ==》 yield 基础产量 amount 在挖人数
    function getPoolAttr(uint256 poolType)
        external
        view
        override
        returns (uint256 yield, uint256 amount)
    {
        LibUintSet.UintSet storage poolStakeSet = _poolStakes[poolType];
        yield = _baseProduct;
        amount = poolStakeSet.getSize();
    }

    //提取用户资源
    function takeReward() external override {
        for (uint256 i = 0; i < rewardPool.length; i++) {
            uint256 amount = rewardPool[i].takeReward(msg.sender);
            amount = amount.add(_plunderAmounts[msg.sender][i]);
            _plunderAmounts[msg.sender][i] = 0;
            if (amount > 0) {
                tokens[i].safeTransfer(msg.sender, amount);
            }
        }
    }

    // //新增一个矿池
    // function newPool(address token,uint poolType) public onlyManager {
    //     require(poolType == rewardPool.length,"This agrument not valid");
    //     tokens.push(IERC20(token));
    //     RewardPool pool = new RewardPool(address(this), _getRewardPerBlock(), block.number);
    //     rewardPool.push(pool);
    // }

    /**
     * 设置矿池基础产出
     */
    function setBaseProduct(uint256 baseProduct, uint256 baseBlockTime)
        public
        onlyManager
    {
        _baseProduct = baseProduct;
        _baseBlockTime = baseBlockTime;
        for (uint256 i = 0; i < rewardPool.length; i++) {
            rewardPool[i].setRewardPerBlock(_getRewardPerBlock());
        }
    }

    //从矿池里提取对应的数量到某个地址。比如矿池作废时取出所有资源。
    function claim(
        address _tokenAddr,
        address _payee,
        uint256 _amount
    ) external onlyOwner {
        require(_payee != address(0), "30006:Payee is zero address");
        require(_amount > 0, "30003:No enough token transfered ");
        IERC20(_tokenAddr).safeTransfer(_payee, _amount);
    }

    function _addTokenToMiningPool(uint256 tokenId, uint256 poolType) private {
        //记录进入这个用户的对应矿池的id
        LibUintSet.UintSet storage minerStakeSet = _minerStakes[msg.sender][
            poolType
        ];
        require(minerStakeSet.add(tokenId), "insert user pool failed");
        //记录进当前矿区的所有英雄id
        LibUintSet.UintSet storage poolStakeSet = _poolStakes[poolType];
        require(poolStakeSet.add(tokenId), "insert pool failed");
        //记录当前这个tokenId归属于这个用户
        _stakes[tokenId] = msg.sender;
    }

    function _removeTokenFromMiningPool(uint256 tokenId, uint256 poolType)
        private
    {
        //移除这个用户在这个矿区下的id
        LibUintSet.UintSet storage minerStakeSet = _minerStakes[
            _stakes[tokenId]
        ][poolType];
        require(minerStakeSet.remove(tokenId), "remove from user pool failed");
        //移除这个矿区下的id
        LibUintSet.UintSet storage poolStakeSet = _poolStakes[poolType];
        require(poolStakeSet.remove(tokenId), "remove form  pool failed");
        //删除用户targetId归属
        delete _stakes[tokenId];
    }

    function _getStakeAmount(uint256 tokenId)
        private
        view
        returns (uint256 stakeAmount)
    {
        uint256 rarity = primalRepo.getPrimalRarity(tokenId);
        stakeAmount = _baseMining[rarity];
        require(stakeAmount > 0, "60004:This NFT is unavailable");
    }

    function _getRandIdFromPool(uint256 poolType)
        private
        returns (uint256 targetId)
    {
        //获取这个池子里的所有NFT 要求NFT里的列表长度大于0 并且池子里NFT列表的长度不等于这个用户池子里NFT列表的长度
        LibUintSet.UintSet storage poolStakeSet = _poolStakes[poolType];
        LibUintSet.UintSet storage minerStakeSet = _minerStakes[msg.sender][
            poolType
        ];
        require(
            poolStakeSet.getSize() > 0 &&
                poolStakeSet.getSize() > minerStakeSet.getSize(),
            "Can't find NFT to plunder"
        );
        //过滤出不属于这个用户的NFT列表
        uint256 size = poolStakeSet.getSize() - minerStakeSet.getSize();
        uint256[] memory randNFTs = new uint256[](size);
        uint256 index = 0;
        for (uint256 i = 0; i < poolStakeSet.getSize(); i++) {
            uint256 id = poolStakeSet.getByIndex(i);
            if (_stakes[id] != msg.sender) {
                randNFTs[index] = id;
                index++;
            }
        }
        //随机从NFT列表里随机出一个NFT
        uint256 randIndex = LibRandom.randMod(size, randNonce.current());
        randNonce.increment();
        targetId = randNFTs[randIndex];
    }

    function _getRewardPerBlock()
        private
        view
        returns (uint256 rewardPerBlock)
    {
        rewardPerBlock = _baseProduct.div(1 hours).mul(_baseBlockTime);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
