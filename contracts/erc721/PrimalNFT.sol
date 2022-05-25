// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTMock.sol";
import "../interface/IPrimalData.sol";
import "@openzeppelin/contracts/utils/Address.sol";



contract PrimalNFT is NFTMock {

    using Address for address;
   
    IPrimalData public primalRepo;
    /**
     * @dev Contract constructor.
     * @param _name A descriptive name for a collection of NFTs.
     * @param _symbol An abbreviated name for NFTokens.
     * @param _uri The base uri
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _primalRepo
    ) NFTMock(_name, _symbol) {
        setBaseURI(_uri);
        primalRepo = IPrimalData(_primalRepo);
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string memory _uri
    ) public onlyRole(MINTER_ROLE) {
        primalRepo.createPrimal(_tokenId);
        super._safeMint(_to, _tokenId);
        super._setTokenURI(_tokenId, _uri);
        
    }

    function setNewPrimalRepo(address _primalRepo) public onlyRole(MINTER_ROLE) {
        require(_primalRepo.isContract(),"This address is not a contract");
        primalRepo = IPrimalData(_primalRepo);
    }


    //获取对应英雄技能的列表
    function getOwndTokensBySkillId(address owner,uint skill) external  view returns (uint[] memory tokenIds) {
        return primalRepo.getOwndTokensBySkillId(owner,skill);
    }

    //获取所有英雄
    function getOwnedTokens(address owner) external view returns (uint[] memory tokenIds) {
        return primalRepo.getOwnedTokens(owner);
    }

    function getPrimalInfo(uint tokenId) public view returns (uint8 stamina, uint8 rarity,uint8 faction,uint8 element,uint[] memory attrs,uint[] memory exists) {
        (stamina,rarity,faction,element) = primalRepo.getPrimalInfo(tokenId);
        attrs = primalRepo.getPrimalAllAttribute(tokenId);
        exists = primalRepo.getPrimalAllSkill(tokenId);
    }

    function getPrimalAllAttribute(uint tokenId)
        external
        view
        returns (uint[] memory attrs) {
        return primalRepo.getPrimalAllAttribute(tokenId);
    }

    function getPrimalAllSkill(uint tokenId)
        external
        view
        returns (uint[] memory exists) {
        return primalRepo.getPrimalAllSkill(tokenId);
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        primalRepo.updateOwner(from,to,tokenId);
        super._afterTokenTransfer(from, to, tokenId);
    }

    function tokenURIBatch(uint256[] memory tokenIds) public view returns (string[] memory) {
        string[] memory batchUris = new string[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            batchUris[i] = tokenURI(tokenIds[i]);
        }
        return batchUris;
    }

  
}
