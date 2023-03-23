// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Will {
    uint256 internal tokenId;
    address internal owner;
    address internal beneficiary ;

    mapping(address => uint256[]) digitalAssetId;
    mapping(address => uint256[]) realAssetId;

    constructor(
        uint256 _tokenId,
        address _owner , 
        address _beneficiary 
    ) {
        owner = _owner;
        tokenId = _tokenId;
        beneficiary = _beneficiary;
    }

}