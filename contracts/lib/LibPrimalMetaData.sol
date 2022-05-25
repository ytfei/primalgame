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

    IERC20 public constant WIND = IERC20(WIND_ADDRESS);
    IERC20 public constant LIFE = IERC20(LIFE_ADDRESS);
    IERC20 public constant WATER = IERC20(WATER_ADDRESS);
    IERC20 public constant FIRE = IERC20(FIRE_ADDRESS);
    IERC20 public constant EARTH = IERC20(EARTH_ADDRESS);
    IERC20 public constant SOURCE = IERC20(SOURCE_ADDRESS);
    IERC20 public constant PRIMALCOIN = IERC20(PRIMALCOIN_ADDRESS);

    
    // struct Attribute {
    //     uint256 hp;//血量
    //     uint256 attack;//攻击
    //     uint256 crit;//暴击
    //     uint256 speed;//速度
    //     uint256 dodge;//闪避
    //     uint256 defense;//防御
    // }

    


}