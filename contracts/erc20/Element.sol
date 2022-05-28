// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// contract class for Air/Earth/Fire/Life/Might/Water, those elements are minted will staking, no fix supplementary.
contract Element is ERC20, Ownable {
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {}

    function mint(address to, uint256 amount)
        public
        onlyOwner
    {
        _mint(to, amount);
    }
}
