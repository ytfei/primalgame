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

    //TODO: deploy contract and replace with new addresses
    IERC20 public constant WIND = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);
    IERC20 public constant LIFE = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);
    IERC20 public constant WATER = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);
    IERC20 public constant FIRE = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);
    IERC20 public constant EARTH = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);
    IERC20 public constant SOURCE = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);
    IERC20 public constant PRIMALCOIN = IERC20(0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3);

    
    // struct Attribute {
    //     uint256 hp;//血量
    //     uint256 attack;//攻击
    //     uint256 crit;//暴击
    //     uint256 speed;//速度
    //     uint256 dodge;//闪避
    //     uint256 defense;//防御
    // }

    


}