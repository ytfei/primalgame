// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../lib/LibRandom.sol";
import "../interface/IPrimalData.sol";
import "../lib/LibPrimalMetaData.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../lib/struct/LibUintSet.sol";

contract PrimalData is IPrimalData,AccessControl{
    using Counters for Counters.Counter;
    using LibUintSet for LibUintSet.UintSet;

    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");

    Counters.Counter public randNonce;
    IERC721 public nftAddress;
    //primal.tokenId => primal attributetype => primalValue 英雄属性
    mapping(uint => mapping(uint => uint)) private _primalAttributes;
    //primal.tokenId => primal skilltype => bool 英雄技能
    mapping(uint => mapping(uint => uint)) private _primalSkills;
    // //primal.tokenId => primal stamina 英雄耐力
    // mapping(uint => uint) public primalStaminas;
    // //primal.tokenId => primal faction 英雄阵营
    // mapping(uint => uint) public primalFactions;
    // //primal.tokenId => primal rarity 英雄稀有度
    // mapping(uint => uint) public primalRaritys;
    // //primal.tokenId => primal element 英雄元素
    // mapping(uint => uint) public primalElement;
    mapping(uint256 => Primal) private _primals;

    //用户拥有的对应技能的英雄
    mapping(address => mapping(uint => LibUintSet.UintSet)) private _ownedSkillTokens;
    //用户具有的英雄
    mapping(address => LibUintSet.UintSet) private _ownedTokens;

    uint[5] private _baseLife = [30,40,50,60,70];
    uint[5] private _baseAttack = [28,36,44,52,60];
    uint[5] private _baseCrit = [5,9,13,17,21];
    uint[5] private _baseSpeed = [10,16,22,28,34];
    uint[5] private _baseDefense = [11,15,19,23,27];
    uint[5] private _baseDodge = [15,21,27,33,39];

    struct Primal {
        uint tokenId;
        uint birth;
        uint8 stamina;
        uint8 rarity;
        uint8 faction;
        uint8 element;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPDATE_ROLE, msg.sender);
    }
    
    modifier isPrimalExist(uint tokenId) {
        require(_primals[tokenId].birth != 0,"This hero is not existed");
        _;
    }

    function setNFTAddress(IERC721 nftAddress_) public  onlyRole(DEFAULT_ADMIN_ROLE) {
        nftAddress = nftAddress_;
    }

    //获取对应英雄技能的列表
    function getOwndTokensBySkillId(address owner,uint skill) external override view returns (uint[] memory tokenIds) {
        return _ownedSkillTokens[owner][skill].getAll();
    }

    //获取所有英雄
    function getOwnedTokens(address owner) external override view returns (uint[] memory tokenIds) {
        return _ownedTokens[owner].getAll();
    }

    function createPrimal(uint256 tokenId) public override onlyRole(UPDATE_ROLE) {
        require(_primals[tokenId].birth == 0,"This hero is existed");
        //随机阵营
        uint faction = LibRandom.randMod(2,randNonce.current());
        randNonce.increment();
        //随机元素
        uint element = LibRandom.randMod(5,randNonce.current());
        randNonce.increment();
        //随机属性
        _generateRandomAttr(uint(LibPrimalMetaData.RarityType.Normal),tokenId);
        //随机技能
        _generateRandomSkill(tokenId);
        _primals[tokenId] = Primal(tokenId,block.timestamp,5,uint8(LibPrimalMetaData.RarityType.Normal),uint8(faction),uint8(element));
    } 

    function updateOwner(address from,address to,uint tokenId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE) {
        //如果from为0 代表是mint to为0 代表是burn
        if (from == address(0)) {
            //mint事件不关注
        } else if (from != to) {
            _removeNftFromEnumeration(from,tokenId);
        }
        if (to == address(0)) {
            //burn事件，移除掉这个英雄
            delete _primals[tokenId];
        } else if (to != from) {
            _addNftToEnumeration(to,tokenId);
        }
    }

    //更新稀有度等级
    function updatePrimal(uint tokenId,uint rarity)  public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE){
        require(rarity <= uint(LibPrimalMetaData.RarityType.Diamond),"This rarity not surport");
        _generateRandomAttr(rarity,tokenId);
        updatePrimalSkill(tokenId);
        Primal storage primal = _primals[tokenId];
        primal.rarity = uint8(rarity);
    }

    //更新英雄的属性
    function updatePrimalAttibute(uint tokenId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE) {
        _generateRandomAttr(_primals[tokenId].rarity,tokenId);
    }

    //更新英雄技能
    function updatePrimalSkill(uint tokenId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE) {
        //先移除掉原来用户的技能列表
        address owner = nftAddress.ownerOf(tokenId);
        uint[] memory exists = this.getPrimalAllSkill(tokenId);
        for (uint256 i = 0; i < exists.length; i++) {
            if(exists[i] == 1) {
                //记录
                LibUintSet.UintSet storage set = _ownedSkillTokens[owner][i];
                set.remove(tokenId);
                //原技能归0
                _primalSkills[tokenId][i] = 0;
            }
        }
        _generateRandomSkill(tokenId);
        //将新技能添加进来
        _addSkillNftToEnumeration(owner,tokenId);
    }

   

    function getPrimalInfo(uint tokenId) public override isPrimalExist(tokenId) view returns (uint8 stamina, uint8 rarity,uint8 faction,uint8 element) {
        rarity = _primals[tokenId].rarity;
        faction = _primals[tokenId].faction;
        element = _primals[tokenId].element;
        stamina = _primals[tokenId].stamina;
    }

    //获取英雄阵营
    function getPrimalFaction(uint tokenId) public override isPrimalExist(tokenId) view returns (uint8 faction) {
        faction = _primals[tokenId].faction;
    }

    function getPrimalRarity(uint tokenId) public override isPrimalExist(tokenId) view returns (uint8 rarity) {
        rarity = _primals[tokenId].rarity;
    }

    //设置英雄阵营
    function setPrimalFaction(uint tokenId,uint factionId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE) {
        require(factionId <= uint(LibPrimalMetaData.FactionType.Devil),"This faction not surport");
        Primal storage primal = _primals[tokenId];
        primal.faction = uint8(factionId);
    }

    //获取英雄元素
    function getPriamlElement(uint tokenId) public override isPrimalExist(tokenId) view returns (uint8 element) {
        element = _primals[tokenId].element;
    }

    //设置英雄元素
    function setPrimalElement(uint tokenId,uint elementId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE) {
        require(elementId <= uint(LibPrimalMetaData.ElementType.Earth),"This element not surport");
        Primal storage primal = _primals[tokenId];
        primal.element = uint8(elementId);
    }

    //获取英雄耐力
    function getPriamlStamina(uint tokenId) public override isPrimalExist(tokenId) view returns (uint8 stamina) {
        stamina = _primals[tokenId].stamina;
    }

    //英雄休整
    function recoverPrimalStamina(uint tokenId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE){
        Primal storage primal = _primals[tokenId];
        require(primal.stamina < 5,"You don't need recover stamina");
        primal.stamina = primal.stamina + 1;
    }

    //英雄减少耐力
    function consumePrimalStamina(uint tokenId) public override isPrimalExist(tokenId) onlyRole(UPDATE_ROLE){
        Primal storage primal = _primals[tokenId];
        if(primal.stamina > 0)
            primal.stamina = primal.stamina - 1; 
    }


    function getPrimalSingleAttribute(uint tokenId, uint attrId)
        external
        override
        isPrimalExist(tokenId)
        view
        returns (uint attr) {
        attr = _primalAttributes[tokenId][attrId];
    }


    function getPrimalAllAttribute(uint tokenId)
        external
        override
        isPrimalExist(tokenId)
        view
        returns (uint[] memory attrs) {
        uint attrLength = uint(LibPrimalMetaData.AttrType.Dodge) + 1;
        attrs = new uint[](attrLength);
        for (uint256 i = 0; i < attrLength; ++i) {
            attrs[i] = _primalAttributes[tokenId][i];
        }
    }

    function getPrimalSingleSkill(uint tokenId, uint skillId)
        external
        override
        isPrimalExist(tokenId)
        view
        returns (uint exist) {
        exist = _primalSkills[tokenId][skillId];
    }


    function getPrimalAllSkill(uint tokenId)
        external
        override
        isPrimalExist(tokenId)
        view
        returns (uint[] memory exists) {
        uint skillLength = uint(LibPrimalMetaData.SkillType.Plunder) + 1;
        exists = new uint[](skillLength);
        for (uint256 i = 0; i < skillLength; ++i) {
            exists[i] = _primalSkills[tokenId][i];
        }
    }
    
    function _addNftToEnumeration(address owner,uint tokenId) private {
        _ownedTokens[owner].add(tokenId);
        _addSkillNftToEnumeration(owner,tokenId);
    }

    function _removeNftFromEnumeration(address owner,uint tokenId) private {
        _removeSkillNftFromEnumeration(owner,tokenId);
        _ownedTokens[owner].remove(tokenId);
    }

    function _addSkillNftToEnumeration(address owner,uint tokenId) private {
        uint[] memory exists = this.getPrimalAllSkill(tokenId);
        for (uint256 i = 0; i < exists.length; i++) {
            if(exists[i] == 1) {
                LibUintSet.UintSet storage set = _ownedSkillTokens[owner][i];
                set.add(tokenId);
            }
        }
    }

    function _removeSkillNftFromEnumeration(address owner,uint tokenId) private {
        uint[] memory exists = this.getPrimalAllSkill(tokenId);
        for (uint256 i = 0; i < exists.length; i++) {
            if(exists[i] == 1) {
                LibUintSet.UintSet storage set = _ownedSkillTokens[owner][i];
                set.remove(tokenId);
            }
        }
    }

    function _generateRandomSkill(uint tokenId) private returns(uint skill) {
        // 1 : 1 : 1 : 1 : 1 : 1 : 2 
        uint skillGene = LibRandom.randMod(8,randNonce.current());
        randNonce.increment();
        skill = skillGene < uint(LibPrimalMetaData.SkillType.Plunder) ? skillGene : uint(LibPrimalMetaData.SkillType.Plunder);
        _primalSkills[tokenId][skill] = 1; 
    }

    function _generateRandomAttr(uint rarity,uint tokenId) private {
        uint life = _generateLife(rarity);
        uint attack = _generateAttack(rarity,life);
        uint crit = _generateCrit(rarity);
        uint speed = _generateSpeed(rarity,crit);
        uint defense = _generateDefense(rarity);
        uint dodge = _generateDodge(rarity,defense);
        _primalAttributes[tokenId][uint(LibPrimalMetaData.AttrType.Hp)] = life;
        _primalAttributes[tokenId][uint(LibPrimalMetaData.AttrType.Attack)] = attack;
        _primalAttributes[tokenId][uint(LibPrimalMetaData.AttrType.Crit)] = crit;
        _primalAttributes[tokenId][uint(LibPrimalMetaData.AttrType.Speed)] = speed;
        _primalAttributes[tokenId][uint(LibPrimalMetaData.AttrType.Defense)] = defense;
        _primalAttributes[tokenId][uint(LibPrimalMetaData.AttrType.Dodge)] = dodge;
    }

    function _generateLife(uint rarity) private returns (uint life) {
        uint lifeGene = LibRandom.randMod(4,randNonce.current());
        randNonce.increment();
        life = _baseLife[rarity] + 5 * lifeGene;
    }

    function _generateAttack(uint rarity,uint life) private view returns (uint attack) {
        attack = _baseAttack[rarity] - (2 * life / 5);
    }

    function _generateSpeed(uint rarity,uint crit) private view returns (uint speed) {
        speed = _baseSpeed[rarity] - crit;
    }

    function _generateDodge(uint rarity,uint defense)  private view returns (uint dodge) {
        dodge = (_baseDodge[rarity] - defense) / 2;
    }

    function _generateCrit(uint rarity) private returns (uint crit) {
        uint critGene = LibRandom.randMod(4,randNonce.current());
        randNonce.increment();
        crit = _baseCrit[rarity] + critGene;
    }


    function _generateDefense(uint rarity) private returns (uint defense) {
        uint defenseGene = LibRandom.randMod(4,randNonce.current());
        randNonce.increment();
        defense = _baseDefense[rarity] + defenseGene;
    }

    
}