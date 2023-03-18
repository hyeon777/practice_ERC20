//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712 {

    bytes32 private DOMAIN_SEPARATOR;

    constructor(string memory name, string memory version) {

    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public returns (bytes32 data) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), DOMAIN_SEPARATOR.offset)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
        //return keccak256(abi.encodePacked(structHash));
    }
    

}