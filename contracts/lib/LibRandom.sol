// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.3;


library LibRandom {
   
    function randMod(uint _modulus,uint randomNonce) internal view returns(uint) {
        return uint(
                keccak256(
                    abi.encodePacked(
                        block.timestamp, 
                        msg.sender, 
                        block.difficulty,
                        blockhash(block.number),
                        block.coinbase,
                        randomNonce
                    )
                ) 
            ) % _modulus;
    }
}


