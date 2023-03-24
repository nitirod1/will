// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Will {
    uint256 internal tokenId;
    address internal owner;
    address internal beneficiary ;

    constructor(
        uint256 _tokenId,
        address _owner 
    ) {
        owner = _owner;
        tokenId = _tokenId;
    }
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function setBeneficiary(address _beneficiary) external isOwner{
        beneficiary = _beneficiary;
    }

    function getBeneficiary()public view returns(address){
        return beneficiary;
    }
}