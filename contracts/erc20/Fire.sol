// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Fire is ERC20 {
    constructor() ERC20("Primal Fire", "FIRE") {
        _mint(msg.sender, 1000000000);
    }
}
