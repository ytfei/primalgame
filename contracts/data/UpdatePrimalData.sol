// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.3;

import "../interface/IPrimalData.sol";
import "../lib/LibPrimalMetaData.sol";
import "../lib/LibRandom.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UpdatePrimalData is Ownable { 
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    //合成事件
    event SynthesisPrimal(address indexed owner, uint time,uint[] tokenIds,uint rarity);
    //恢复耐力事件
    event RecoverPrimal(address indexed owner,uint time ,uint tokenId);

    //恢复耐力事件
    event RemintPrimal(address indexed owner,uint time ,uint tokenId);
    //质押的NFT地址
    IERC721 public nftAddress; // Desposit nft address
    //数据仓库地址
    IPrimalData public primalRepo;

    address public pve;
    //修整数据
    uint[5] private _baseRecoverElementAmount = [100,300,900,2700,8100];
    uint[5] private _baseRecoverCommonAmount = [40,120,360,1080,3240];

    //修整数据
    uint[5] private _baseRemintElementAmount = [2000,4000,10000,20000,40000];
    uint[5] private _baseRemintCommonAmount = [800,1600,4000,8000,16000];

    //合成数据
    uint[4] private _baseSynthesisElementAmount = [2000,4000,10000,20000];
    uint[4] private _baseSynthesisCommonAmount = [800,1600,4000,8000];
    //每个稀有度等级能向上合成的概率
    mapping(uint => mapping(uint => uint)) _updateRate;

    constructor(address _nftAddress,IPrimalData _primalRepo,address _pve) {
        nftAddress = IERC721(_nftAddress);
        primalRepo = _primalRepo;
        pve = _pve;
        _updateRate[uint(LibPrimalMetaData.RarityType.Normal)][uint(LibPrimalMetaData.RarityType.Green)] = 200;
        _updateRate[uint(LibPrimalMetaData.RarityType.Normal)][uint(LibPrimalMetaData.RarityType.Blue)] = 30;
        _updateRate[uint(LibPrimalMetaData.RarityType.Green)][uint(LibPrimalMetaData.RarityType.Blue)] = 150;
        _updateRate[uint(LibPrimalMetaData.RarityType.Green)][uint(LibPrimalMetaData.RarityType.Gold)] = 15;
        _updateRate[uint(LibPrimalMetaData.RarityType.Blue)][uint(LibPrimalMetaData.RarityType.Gold)] = 100;
        _updateRate[uint(LibPrimalMetaData.RarityType.Blue)][uint(LibPrimalMetaData.RarityType.Diamond)] = 5;
        _updateRate[uint(LibPrimalMetaData.RarityType.Gold)][uint(LibPrimalMetaData.RarityType.Diamond)] = 50;
    }
    //初始时候有6个ERC20的token地址
    IERC20[] public tokens = [LibPrimalMetaData.WIND,LibPrimalMetaData.LIFE,LibPrimalMetaData.WATER,LibPrimalMetaData.FIRE,LibPrimalMetaData.EARTH,LibPrimalMetaData.SOURCE];

    //恢复英雄耐力
    function recoverPrimalStamina(uint tokenId) public {
        uint[] memory elementAmount = getRecoverPrimalStamina(tokenId);
        //消耗转移
        for (uint i = 0; i < elementAmount.length; i++) { 
            if(elementAmount[i] > 0) {
                tokens[i].safeTransferFrom(msg.sender,address(this), elementAmount[i]);
            }
        }
       
        primalRepo.recoverPrimalStamina(tokenId);
        emit RecoverPrimal(msg.sender,block.timestamp,tokenId);
    }

    //英雄重铸属性
    function remintPrimalAttr(uint tokenId) public {
        uint[] memory elementAmount = getRemintPrimalAttr(tokenId);
        //消耗转移
        for (uint i = 0; i < elementAmount.length; i++) { 
            if(elementAmount[i] > 0) {
                tokens[i].safeTransferFrom(msg.sender,address(this), elementAmount[i]);
            }
        }
        primalRepo.updatePrimalAttibute(tokenId,primalRepo.getPrimalRarity(tokenId));
        emit RemintPrimal(msg.sender,block.timestamp,tokenId);
    }

    //获取英雄回复需要的资源
    function getRecoverPrimalStamina(uint tokenId) public view returns(uint[] memory elementAmount) {
        elementAmount = new uint[](6);
        //判断这个NFT是否归属于用户
        require(nftAddress.ownerOf(tokenId) == msg.sender,"60003:This nft not belong to you");
        //获取属性元素和通用元素消耗
        uint8 rarity = primalRepo.getPrimalRarity(tokenId);
        uint baseAmount = _baseRecoverElementAmount[rarity];
        uint baseCommonAmount = _baseRecoverCommonAmount[rarity];
        //获取英雄属性
        uint8 element = primalRepo.getPriamlElement(tokenId);
        // 风需要生命 生命-水 水-火 火-土 大地-风
        element = element == uint8(LibPrimalMetaData.ElementType.Earth) ? uint8(LibPrimalMetaData.ElementType.Wind) : element + 1;
        elementAmount[element] = baseAmount;
        elementAmount[uint(LibPrimalMetaData.PoolType.Source)] = baseCommonAmount;
    }

     //获取英雄重铸需要的资源
    function getRemintPrimalAttr(uint tokenId) public view returns(uint[] memory elementAmount) {
        elementAmount = new uint[](6);
        //判断这个NFT是否归属于用户
        require(nftAddress.ownerOf(tokenId) == msg.sender,"60003:This nft not belong to you");
        //获取属性元素和通用元素消耗
        uint8 rarity = primalRepo.getPrimalRarity(tokenId);
        uint baseAmount = _baseRemintElementAmount[rarity];
        uint baseCommonAmount = _baseRemintCommonAmount[rarity];
        //获取英雄属性
        uint8 element = primalRepo.getPriamlElement(tokenId);
        elementAmount[element] = baseAmount;
        elementAmount[uint(LibPrimalMetaData.PoolType.Source)] = baseCommonAmount;
    }

    //合成英雄
    function synthesisPrimal(uint[] memory tokenIds) public  {
        require(tokenIds.length > 1,"The hero too less");
        //获取消耗的数目，和升级的概率
        (uint[] memory elementAmount,uint[] memory rate) = getSynthesisPrimalConsume(tokenIds);
        for (uint256 i = 0; i < elementAmount.length; i++) { 
            if(elementAmount[i] > 0) {
                tokens[i].safeTransferFrom(msg.sender,address(this), elementAmount[i]);
            }
        }
        //对第一个nftid升级
        uint rarity = 0;
        uint random = LibRandom.randMod(100,block.timestamp);
        for(uint i = 4;i >= 0;i--) {
            if(random < rate[i]) {
                rarity = i;
                primalRepo.updatePrimal(tokenIds[0],i);
                break;
            }
        }
        //转移走剩下的nftid
        for (uint256 i = 1; i < tokenIds.length; i++) { 
            nftAddress.safeTransferFrom(msg.sender,pve,tokenIds[i]);
        }
        emit SynthesisPrimal(msg.sender,block.timestamp,tokenIds,rarity);
    }

    //获取合成所需要的资源。返回资源消耗数组和概率数组
    function getSynthesisPrimalConsume(uint[] memory tokenIds) public view returns(uint[] memory elementAmount,uint[] memory rate) {
        elementAmount = new uint[](6);
        rate = new uint[](5);
        uint maxLevel = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) { 
            uint tokenId = tokenIds[i];
            require(nftAddress.ownerOf(tokenId) == msg.sender,"60003:This nft not belong to you");
            uint8 rarity = primalRepo.getPrimalRarity(tokenId);
            //记录最高等级
            maxLevel = rarity > maxLevel ? rarity : maxLevel;
            require(rarity < uint8(LibPrimalMetaData.RarityType.Diamond),"This nft is highest level");
            //获取元素需要消耗的数量和源生矿需要消耗的数量
            uint baseAmount = _baseSynthesisElementAmount[rarity];
            uint baseCommonAmount = _baseSynthesisCommonAmount[rarity];
            uint8 element = primalRepo.getPriamlElement(tokenId);
            //记录元素矿
            elementAmount[element] = elementAmount[element].add(baseAmount);
            //记录源生矿
            elementAmount[uint(LibPrimalMetaData.PoolType.Source)] = elementAmount[uint(LibPrimalMetaData.PoolType.Source)].add(baseCommonAmount);
            rate[0] = rate[0].add(_updateRate[rarity][uint(LibPrimalMetaData.RarityType.Normal)]);
            rate[1] = rate[1].add(_updateRate[rarity][uint(LibPrimalMetaData.RarityType.Green)]);
            rate[2] = rate[2].add(_updateRate[rarity][uint(LibPrimalMetaData.RarityType.Blue)]);
            rate[3] = rate[3].add(_updateRate[rarity][uint(LibPrimalMetaData.RarityType.Gold)]);
            rate[4] = rate[4].add(_updateRate[rarity][uint(LibPrimalMetaData.RarityType.Diamond)]);
        }
        if(maxLevel > 0) {
            //最低为当前最高品质。小于的全部设为0
            for (uint256 i = 0; i < maxLevel; i++) { 
                rate[i] = 0;
            }
            //获取保底概率是多少
            uint totalRate = 0;
            for(uint i = 4;i > maxLevel;i--) {
                totalRate = totalRate.add(rate[i]);
            }
            rate[maxLevel] = uint(1000).sub(totalRate);
        } else {
            //最高品质等级为0时的
            rate[0] = uint(1000).sub(rate[4]).sub(rate[3]).sub(rate[2]).sub(rate[1]);
        }
    }

    //从矿池里提取对应的数量到某个地址。比如矿池作废时取出所有资源。
    function claim(address _tokenAddr,address _payee,uint256 _amount) external onlyOwner {
        require(_payee != address(0),"30006:Payee is zero address");
        require(_amount > 0,"30003:No enough token transfered ");
        IERC20(_tokenAddr).safeTransfer(_payee, _amount);
    }

    function setNFTAddress(IERC721 nftAddress_) public  onlyOwner {
        nftAddress = nftAddress_;
    }

    function setRepoAddress(IPrimalData repo_) public  onlyOwner {
        primalRepo = repo_;
    }

    function setPVEAddress(address pve_) public  onlyOwner {
        pve = pve_;
    }




}