// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * Primal Data is responsible for managing the NFT data, while ERC721 implementation PrimalNFT will take care of the data storage (write and read)
 */

interface IPrimalData {
    //创建一个新的英雄
    function createPrimal(uint256 tokenId) external;

    //变更tokenId的归属权。
    function updateOwner(
        address from,
        address to,
        uint256 tokenId
    ) external;

    //获取对应英雄技能的列表
    function getOwndTokensBySkillId(address owner, uint256 skill)
        external
        view
        returns (uint256[] memory tokenIds);

    //获取所有英雄
    function getOwnedTokens(address owner)
        external
        view
        returns (uint256[] memory tokenIds);

    function getPrimalInfo(uint256 tokenId)
        external
        view
        returns (
            uint8 stamina,
            uint8 rarity,
            uint8 faction,
            uint8 element
        );

    //重铸英雄的属性
    function updatePrimalAttibute(uint256 tokenId, uint256 rarity) external;

    //重铸英雄的技能
    function updatePrimalSkill(uint256 tokenId) external;

    //合成的英雄
    function updatePrimal(uint256 tokenId, uint256 rarity) external;

    //获取英雄阵营
    function getPrimalFaction(uint256 tokenId)
        external
        view
        returns (uint8 faction);

    //获取英雄稀有度
    function getPrimalRarity(uint256 tokenId)
        external
        view
        returns (uint8 rarity);

    //设置英雄阵营
    function setPrimalFaction(uint256 tokenId, uint256 factionId) external;

    //获取英雄元素
    function getPriamlElement(uint256 tokenID)
        external
        view
        returns (uint8 element);

    //设置英雄元素
    function setPrimalElement(uint256 tokenId, uint256 elementId) external;

    //获取英雄耐力
    function getPriamlStamina(uint256 tokenId)
        external
        view
        returns (uint8 stamina);

    //英雄休整
    function recoverPrimalStamina(uint256 tokenId) external;

    //英雄耐力减少
    function consumePrimalStamina(uint256 tokenId) external;

    //获取英雄的属性
    function getPrimalSingleAttribute(uint256 tokenId, uint256 attrId)
        external
        view
        returns (uint256 attr);

    //获取英雄的所有属性
    function getPrimalAllAttribute(uint256 tokenId)
        external
        view
        returns (uint256[] memory attrs);

    //获取英雄的技能
    function getPrimalSingleSkill(uint256 tokenId, uint256 skillId)
        external
        view
        returns (uint256 exist);

    //获取英雄的所有技能 技能长度是否要扩展，需要扩展则需要在枚举类增加占位符
    function getPrimalAllSkill(uint256 tokenId)
        external
        view
        returns (uint256[] memory exists);
}
