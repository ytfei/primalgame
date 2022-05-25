// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../lib/struct/LibUintSet.sol";

contract UintSetDemo {
    using LibUintSet for LibUintSet.UintSet;
   
    LibUintSet.UintSet private uintSet;

    function add(uint a) public returns (bool) {
        return uintSet.add(a);
    }

    function contains(uint a) public view returns (bool) {
        return uintSet.contains(a);
    }

    function getAll() public view returns (uint[] memory) {
        return uintSet.getAll();
    }


    function remove(uint del) public  returns (bool, uint[] memory) {
        bool b = uintSet.remove(del);
        return (b, uintSet.getAll());
    }

    

    function removeAndAtPositon(uint del, uint key)
        public
        returns (bool, uint)
    {
        uintSet.remove(del);
        return uintSet.atPosition(key);
    }

    function getSize() public view returns (uint) {
        return uintSet.getSize();
    }

    function getByIndex(uint index) public view returns (uint) {
        return uintSet.getByIndex(index);
    }
}
