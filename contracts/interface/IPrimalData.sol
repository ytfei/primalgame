// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



interface IPrimalData  {

    //创建一个新的英雄
    function createPrimal(uint tokenId) external;

    //变更tokenId的归属权。
    function updateOwner(address from,address to,uint tokenId) external;

    //获取对应英雄技能的列表
    function getOwndTokensBySkillId(address owner,uint skill) external view returns (uint[] memory tokenIds);
    
    //获取所有英雄
    function getOwnedTokens(address owner) external view returns (uint[] memory tokenIds);

    function getPrimalInfo(uint tokenId) external view returns (uint8 stamina, uint8 rarity,uint8 faction,uint8 element );

    //重铸英雄的属性
    function updatePrimalAttibute(uint tokenId) external;

    //重铸英雄的技能
    function updatePrimalSkill(uint tokenId) external;

    //合成的英雄
    function updatePrimal(uint tokenId,uint rarity) external;

    //获取英雄阵营
    function getPrimalFaction(uint tokenId) external view returns (uint8 faction);


    //获取英雄阵营
    function getPrimalRarity(uint tokenId) external view returns (uint8 rarity);

    //设置英雄阵营
    function setPrimalFaction(uint tokenId,uint factionId) external;

    //获取英雄元素
    function getPriamlElement(uint tokenID) external view returns (uint8 element);

    //设置英雄元素
    function setPrimalElement(uint tokenId,uint elementId) external;

    //获取英雄耐力
    function getPriamlStamina(uint tokenId) external view returns (uint8 stamina);

    //英雄休整
    function recoverPrimalStamina(uint tokenId) external;
    
    //英雄耐力减少
    function consumePrimalStamina(uint tokenId) external;

    //获取英雄的属性
    function getPrimalSingleAttribute(uint tokenId, uint attrId)
        external
        view
        returns (uint attr);

    //获取英雄的所有属性
    function getPrimalAllAttribute(uint tokenId)
        external
        view
        returns (uint[] memory attrs);

    //获取英雄的技能  
    function getPrimalSingleSkill(uint tokenId, uint skillId)
        external
        view
        returns (uint exist);

    //获取英雄的所有技能 技能长度是否要扩展，需要扩展则需要在枚举类增加占位符
    function getPrimalAllSkill(uint tokenId)
        external
        view
        returns (uint[] memory exists);

}