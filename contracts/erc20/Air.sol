// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Air is ERC20, Ownable {
    constructor() ERC20("Primal Air", "AIR") {}

    function mint(address to, uint256 amount)
        public
        onlyOwner
        returns (uint256)
    {
        _mint(to, amount);

        return amount;
    }
}