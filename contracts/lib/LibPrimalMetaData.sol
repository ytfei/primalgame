// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibPrimalMetaData {
    //阵营
    enum FactionType {
        Angel,
        Devil
    }

    //稀有度
    enum RarityType {
        Normal,
        Green,
        Blue,
        Gold,
        Diamond
    }

    //元素
    enum ElementType {
        Wind,//风
        Life,//生命
        Water,//水
        Fire,//火
        Earth//土
    }

    //矿类型
    enum PoolType {
        Wind,//风 0
        Life,//生命 1
        Water,//水 2
        Fire,//火 3
        Earth,//土 4
        Source //源生矿 5
    }

    //属性
    enum AttrType {
        Hp,//生命
        Attack,//攻击
        Crit,//暴击
        Speed,//速度
        Defense,//防御
        Dodge // 闪避
    }


    enum SkillType {
        WindAffinity,//风元素亲和
        LifeAffinity,//生命
        WaterAffinity,//水
        FireAffinity,//火
        EarthAffinity,//土
        SourceAffinity,//源生亲和
        Plunder
    }

    // TODO: deploy contract and replace with new addresses
// Mote is deployed to: 0x444e866cbbE74ccec258b939b9246682c894F734
// Earth is deployed to: 0x32E0259b6659a0F72e88104B0B70Fc6f2CFcA69f
// Fire is deployed to: 0xBf48470E1858AB44DD3a8F7A6b9d6BBE22F84363
// Life is deployed to: 0x09bc45Ca128856F1e33e09762500BC6dacf3A59C
// Water is deployed to: 0xb855779719d96ca2f1F3580E9c00C9B5eC460260
// Air is deployed to: 0xdd9a33A07D22C60ad2D7E1Db5d02a6f4973151C1
// Might is deployed to: 0x29C27a8fFd81532CfC3E51945568AAaf26163F5f
    IERC20 public constant WIND = IERC20(0xdd9a33A07D22C60ad2D7E1Db5d02a6f4973151C1); // Air
    IERC20 public constant LIFE = IERC20(0x09bc45Ca128856F1e33e09762500BC6dacf3A59C); 
    IERC20 public constant WATER = IERC20(0xb855779719d96ca2f1F3580E9c00C9B5eC460260);
    IERC20 public constant FIRE = IERC20(0xBf48470E1858AB44DD3a8F7A6b9d6BBE22F84363);
    IERC20 public constant EARTH = IERC20(0x32E0259b6659a0F72e88104B0B70Fc6f2CFcA69f);
    IERC20 public constant SOURCE = IERC20(0x29C27a8fFd81532CfC3E51945568AAaf26163F5f); // Might 原始力量，原力
    IERC20 public constant PRIMALCOIN = IERC20(0x444e866cbbE74ccec258b939b9246682c894F734); // Mote  微粒，用于合成其它的资源

    
    // struct Attribute {
    //     uint256 hp;//血量
    //     uint256 attack;//攻击
    //     uint256 crit;//暴击
    //     uint256 speed;//速度
    //     uint256 dodge;//闪避
    //     uint256 defense;//防御
    // }

    


}