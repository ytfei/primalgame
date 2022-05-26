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
    // Coin is deployed to: 0x669F2f448f248103eA3dcc12A7F49E559AFf7A2A
    // Earth is deployed to: 0x0C059ddD14DE7F07c7fAec7e59a60c7bc610ea28
    // Fire is deployed to: 0xb46Da3E5a1798E1f4f6965836Bd65424Ef02C8ee
    // Life is deployed to: 0x7b92fDe64b15773D2C240C58AE4508E0A5ac5B4F
    // Water is deployed to: 0xB2Fea2b212aD2AA230967084dA78eE4622A59617
    // Wind is deployed to: 0xff975B63489E384CD481352C93a17fc3841b1614
    // Source is deployed to: 0x54d3BdD5e7EE6bb0A900B1CbF1a0df144D9122df
    IERC20 public constant WIND = IERC20(0xff975B63489E384CD481352C93a17fc3841b1614);
    IERC20 public constant LIFE = IERC20(0x7b92fDe64b15773D2C240C58AE4508E0A5ac5B4F);
    IERC20 public constant WATER = IERC20(0xB2Fea2b212aD2AA230967084dA78eE4622A59617);
    IERC20 public constant FIRE = IERC20(0xb46Da3E5a1798E1f4f6965836Bd65424Ef02C8ee);
    IERC20 public constant EARTH = IERC20(0x0C059ddD14DE7F07c7fAec7e59a60c7bc610ea28);
    IERC20 public constant SOURCE = IERC20(0x54d3BdD5e7EE6bb0A900B1CbF1a0df144D9122df);
    IERC20 public constant PRIMALCOIN = IERC20(0x669F2f448f248103eA3dcc12A7F49E559AFf7A2A);

    
    // struct Attribute {
    //     uint256 hp;//血量
    //     uint256 attack;//攻击
    //     uint256 crit;//暴击
    //     uint256 speed;//速度
    //     uint256 dodge;//闪避
    //     uint256 defense;//防御
    // }

    


}