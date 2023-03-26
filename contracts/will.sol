// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Will {
    string internal name;
    uint256 internal idCard;
    uint256 internal tokenId;
    address internal owner;
    address internal beneficiary ;
    uint256 internal balance;

    constructor(
        string memory _name,
        uint256 _idCard,
        uint256 _tokenId,
        address _owner ,
        uint256 _balance
    ) {
        name = _name;
        idCard = _idCard;
        owner = _owner;
        tokenId = _tokenId;
        balance = _balance;
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

    function getIdCard() public view returns(uint256){
        return idCard;
    }

    function setIdCard() public view returns(uint256){
        return idCard;
    }
    
}