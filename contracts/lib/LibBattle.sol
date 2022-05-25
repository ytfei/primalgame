// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "../interface/IPrimalData.sol";
import "../lib/LibPrimalMetaData.sol";
import "./LibRandom.sol";

library LibBattle  {


    //风0 生命1 水2 火4 土4
    function restraint(uint attackElement , uint defenseElement) 
        internal 
        pure 
        returns (bool){
        if(attackElement == uint(LibPrimalMetaData.ElementType.Wind) && defenseElement == uint(LibPrimalMetaData.ElementType.Life)){ // 风克生命
            return true;
        } else if(attackElement == uint(LibPrimalMetaData.ElementType.Life) && defenseElement == uint(LibPrimalMetaData.ElementType.Water)){ // 生命克水
            return true;
        } else if(attackElement == uint(LibPrimalMetaData.ElementType.Water) && defenseElement == uint(LibPrimalMetaData.ElementType.Fire)){ // 水克火
            return true;
        } else if(attackElement == uint(LibPrimalMetaData.ElementType.Fire) && defenseElement == uint(LibPrimalMetaData.ElementType.Earth)){ // 火克大地
            return true;
        } else if(attackElement == uint(LibPrimalMetaData.ElementType.Earth) && defenseElement == uint(LibPrimalMetaData.ElementType.Wind)){ // 大地克风
            return true; 
        } else {
            return false;
        }
    }




    //一个回合的伤害 生命0 攻击1 暴击2 速度3 防御4 闪避5
    function damage(uint[] memory primalAttrs, uint[] memory targetAttrs,bool isRestraint,uint round) internal view returns (uint) {
        //攻击方攻击
        uint attackValue = primalAttrs[uint(LibPrimalMetaData.AttrType.Attack)];
        //攻击方暴击
        uint critValue = primalAttrs[uint(LibPrimalMetaData.AttrType.Crit)];
        //防御方防御
        uint defenseValue = targetAttrs[uint(LibPrimalMetaData.AttrType.Defense)];
        //防御方闪避
        uint dodgeValue = targetAttrs[uint(LibPrimalMetaData.AttrType.Dodge)];
        //判断是否相克
        if(isRestraint) {
            attackValue = attackValue + attackValue * 20 / 100;
        }
        //判断本轮防御方是否闪避
        bool isDodge = LibRandom.randMod(100,round) < dodgeValue ;
        if(isDodge)
            return 0;
        //判断本轮攻击方是否暴击
        bool isCrit = LibRandom.randMod(100,round + 1) < critValue;
        if (isCrit) {
            attackValue = attackValue + attackValue * 50 / 100;
        }
        //这里的防御是防御率。。
        return attackValue * (100 - defenseValue);
    } 

    //侵略如火 ==> 两个人决斗 生命0 攻击1 暴击2 速度3 防御4 闪避5
    function battle(uint primalId, uint targetId,IPrimalData primalRepo) internal view returns(bool,bool,uint[] memory) {
        //获取两个干架人的属性
        uint[] memory primalAttrs = primalRepo.getPrimalAllAttribute(primalId);
        uint[] memory targetAttrs = primalRepo.getPrimalAllAttribute(targetId);
        //其疾如风 ==> 判断谁先出手
        bool first = primalAttrs[uint(LibPrimalMetaData.AttrType.Speed)] >= targetAttrs[uint(LibPrimalMetaData.AttrType.Speed)]; 

        bool isRestraint = restraint(primalRepo.getPriamlElement(primalId),primalRepo.getPriamlElement(targetId));
        // 获取我方和敌方生命
        uint myHP = primalAttrs[uint(LibPrimalMetaData.AttrType.Hp)] * 100;
        uint targetHP = targetAttrs[uint(LibPrimalMetaData.AttrType.Hp)] * 100;
        uint256[] memory fight = new uint256[](20);
        //记录回合数
        uint i = 0;
        //两方一直打到一方归0为止
        while(myHP > 0 && targetHP > 0){
            uint damageNum = 0;
            if(first==true && i%2 == 0) { // 我方先攻，偶数回合 0 2 4 6 8
                damageNum = damage(primalAttrs, targetAttrs,isRestraint,i);
                targetHP = lessZero(targetHP, damageNum);
            }else if(first==false && i%2 == 0) { // 敌方先攻，偶数回合
                damageNum = damage(targetAttrs, primalAttrs,!isRestraint,i);
                myHP = lessZero(myHP, damageNum);
            } else if(first==false && i%2 == 1) { // 敌方先攻，奇数回合
                damageNum = damage(primalAttrs, targetAttrs,isRestraint,i);
                targetHP = lessZero(targetHP, damageNum);
            } else { // 我方先攻，奇数回合 1 3 5 7 9
                damageNum = damage(targetAttrs, primalAttrs,!isRestraint,i);
                myHP = lessZero(myHP, damageNum);
            }
            // 记录下每次攻击的伤害
            fight[i] = damageNum;
            i++;
            
        }
        return (myHP > targetHP,first,fight);
        // return fight;
    }

    // //一个回合的伤害 生命0 攻击1 暴击2 速度3 防御4 闪避5
    // function damageTest(uint primalId, uint targetId,IPrimalData primalRepo,uint round) public view returns (uint) {
    //     //获取两个干架人的属性
    //     uint[] memory primalAttrs = primalRepo.getPrimalAllAttribute(primalId);
    //     uint[] memory targetAttrs = primalRepo.getPrimalAllAttribute(targetId);
    //     bool isRestraint = restraint(primalRepo.getPriamlElement(primalId),primalRepo.getPriamlElement(targetId));
    //     //攻击方攻击
    //     uint attackValue = primalAttrs[1];
    //     //攻击方暴击
    //     uint critValue = primalAttrs[2];
    //     //防御方防御
    //     uint defenseValue = targetAttrs[4];
    //     //防御方闪避
    //     uint dodgeValue = targetAttrs[5];
    //     //判断是否相克
    //     if(isRestraint) {
    //         attackValue = attackValue + attackValue * 20 / 100;
    //     }
    //     //判断本轮防御方是否闪避
    //     bool isDodge = LibRandom.randMod(100,round) < dodgeValue ;
    //     if(isDodge)
    //         return 0;
    //     //判断本轮攻击方是否暴击
    //     bool isCrit = LibRandom.randMod(100,round + 1) < critValue;
    //     if (isCrit) {
    //         attackValue = attackValue + attackValue * 50 / 100;
    //     }
    //     //这里的防御是防御率。。
    //     return attackValue * (100 - defenseValue) ;
    // } 

    // //侵略如火 ==> 两个人决斗 生命0 攻击1 暴击2 速度3 防御4 闪避5
    // function battle2(uint primalId, uint targetId,IPrimalData primalRepo) internal view returns(uint[] memory) {
    //     //获取两个干架人的属性
    //     uint[] memory primalAttrs = primalRepo.getPrimalAllAttribute(primalId);
    //     uint[] memory targetAttrs = primalRepo.getPrimalAllAttribute(targetId);
    //     //其疾如风 ==> 判断谁先出手
    //     bool first = primalAttrs[3] >= targetAttrs[3]; 

    //     // 获取我方和敌方生命
    //     uint myHP = primalAttrs[0] * 100;
    //     uint targetHP = targetAttrs[0] * 100;
    //     uint256[] memory fight = new uint256[](10);
    //     //记录回合数
    //     uint i = 0;
    //     //两方一直打到一方归0为止
    //     while(myHP > 0 && targetHP > 0){
    //         uint damageNum = 0;
    //         if(first==true && i%2 == 0) { // 我方先攻，偶数回合 0 2 4 6 8
    //             damageNum = damageTest(primalId, targetId,primalRepo,i);
    //             targetHP = lessZero(targetHP, damageNum);
    //         }else if(first==false && i%2 == 0) { // 敌方先攻，偶数回合
    //             damageNum = damageTest(targetId, primalId,primalRepo,i);
    //             myHP = lessZero(myHP, damageNum);
    //         } else if(first==false && i%2 == 1) { // 敌方先攻，奇数回合
    //             damageNum = damageTest(primalId, targetId,primalRepo,i);
    //             targetHP = lessZero(targetHP, damageNum);
    //         } else { // 我方先攻，奇数回合 1 3 5 7 9
    //             damageNum = damageTest(targetId, primalId,primalRepo,i);
    //             myHP = lessZero(myHP, damageNum);
    //         }
    //         i++;
    //          // 记录下每次攻击的伤害
    //         fight[i] = damageNum;
    //     }
    //     // return myHP > targetHP;
    //     return fight;
    // }

    function lessZero(uint num, uint minus) internal pure returns(uint) {
        if(num <= minus){
            return 0;
        }else{
            return (num - minus);
        }
    }
}


contract BattleTest {

    function battle(uint primalId, uint targetId,IPrimalData primalRepo) public view returns(bool,bool,uint[] memory) {
        return LibBattle.battle(primalId,targetId,primalRepo); 
    }
    // function battle(uint primalId, uint targetId,IPrimalData primalRepo) public view returns(uint[] memory) { 
    //     return LibBattle.battle(primalId,targetId,primalRepo);
    // }

    // function battleTest(uint primalId, uint targetId,IPrimalData primalRepo) public view returns(uint[] memory) { 
    //     return LibBattle.battle2(primalId,targetId,primalRepo);
    // }
}


 