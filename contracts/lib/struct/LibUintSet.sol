// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 提供uint集合类型操作，包括新增元素，删除元素，获取元素等

library LibUintSet {

    struct UintSet {
        uint[] values;
        mapping(uint => uint) indexes;
    }

    /**
    *@dev uint集合是否包含某个元素
    *@param  set uint类型集合
    *@param  val 待验证的值
    *@return bool 是否包含该元素，true 包含；false 不包含
    **/
    function contains(UintSet storage  set, uint val) internal view returns (bool) {
        return set.indexes[val] != 0;
    }

    /**
    *@dev uint集合，增加一个元素
    *@param  set uint类型集合
    *@param  val 待增加的值
    *@return bool 是否成功添加了元素
    **/
    function add(UintSet storage set, uint val) internal  returns (bool) {

        if(!contains(set, val)){
            set.values.push(val);
            set.indexes[val] = set.values.length;
            return true;
        }
        return false;
    }

    /**
    *@dev uint集合，删除一个元素
    *@param  set uint类型集合
    *@param  val 待删除的值
    *@return bool 是否成功删除了元素
    **/
    function remove(UintSet storage set, uint val) internal returns (bool) {

        uint valueIndex = set.indexes[val];

        if(contains(set,val)){
            uint toDeleteIndex = valueIndex - 1;
            uint lastIndex = set.values.length - 1;

            if(toDeleteIndex != lastIndex){
                uint lastValue = set.values[lastIndex];
                set.values[toDeleteIndex] = lastValue;
                set.indexes[lastValue] = valueIndex;
            }

            delete set.values[lastIndex];
            delete set.indexes[val];
            // set.values.length--;
            set.values.pop();
            return true;
        }

        return false;
    }

    /**
    *@dev    获取集合中的所有元素
    *@param  set uint类型集合
    *@return uint[] 返回集合中的所有元素
    **/
    function getAll(UintSet storage set) internal view returns (uint[] memory) {
        return set.values;
    }

    /**
    *@dev    获取集合中元素的数量
    *@param  set uint类型集合
    *@return uint 集合中元素数量
    **/
    function getSize(UintSet storage set) internal view returns (uint) {
        return set.values.length;
    }

    /**
    *@dev 某个元素在集合中的位置
    *@param  set uint类型集合
    *@param  val 待查找的值
    *@return bool,uint 是否存在此元素与该元素的位置
    **/
    function atPosition (UintSet storage set, uint val) internal view returns (bool, uint) {
        if(contains(set, val)){
            return (true, set.indexes[val]-1);
        }
        return (false, 0);
    }

    /**
    *@dev 替换set内所有的元素
    *@param  set uint类型集合
    *@param newValues 新值的集合
    **/
    function replaceAll(UintSet storage set,uint[] memory newValues) public returns (bool) {
        if(set.values.length == newValues.length) {
            uint[] memory oldValues = set.values;
            for (uint256 i = 0; i < newValues.length; i++) {
               remove(set,oldValues[i]);
            }
            for (uint256 i = 0; i < newValues.length; i++) {
                add(set,newValues[i]);
            }
            return true;
        }
        return false;
        
        
    }

    /**
    *@dev 根据索引获取集合中的元素
    *@param  set uint类型集合
    *@param  index 索引
    *@return uint 查找到的元素
    **/
    function getByIndex(UintSet storage set, uint index) internal view returns (uint) {
        require(index < set.values.length,"Index: index out of bounds");
        return set.values[index];
    }

}