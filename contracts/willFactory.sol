//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "./WillToken.sol";
import "./Will.sol";

contract WillFactory {
    address internal CONTROLLER;
    address internal willTokenAddress;
    address internal realTokenAddress;
    // ? uint256 tokenid , ? address (will)
    // getTokenIdOfWill => will address , getTokenIdOnwer  => array of uint storage tokenid
    // address(contract) = contract will ? if don't have i can เพิ่มเติมได้
    mapping(address => uint256[]) internal tokenIdOwner;
    mapping(uint256 => address) internal tokendIdOfWill;

    event CreateWill(address _will, address _owner);
    event RegisterIdCard(address _owner, uint256 _idCard);

    constructor() {
        CONTROLLER = msg.sender;
    }

    modifier onlyController{
        require(msg.sender == CONTROLLER, "you are not controller ");
        _;
    }
    // tokenid = address(will)
    // mint will -> will 1 
    // verify will ->
    function getTokendIdOfWill(uint256 _tokendId) public view returns(address) {
        return tokendIdOfWill[_tokendId];
    }

    function getTokenIdOnwer(address _owner)public view returns(uint256[] memory) {
        return tokenIdOwner[_owner];
    }

    // createwil -> mint nft -> approve will contract -> metamask approved 
    function createWill(
        string memory _name,
        string memory _description
    ) external {
        require(willTokenAddress != address(0),"address will token unset now !");
        Will will = new Will(msg.sender , willTokenAddress , realTokenAddress, _name, _description);
        uint256 tokendId = WillToken(willTokenAddress).mintWill(msg.sender);
        tokendIdOfWill[tokendId] = address(will);
        tokenIdOwner[msg.sender].push(tokendId);
    }

    function claimWill(address _willContract , uint256 _tokenId )external {
        address beneficiary = Will(_willContract).getBeneficiary();
        address owner = Will(_willContract).getOwner();
        require(beneficiary != address(0)  && owner!=address(0),"address beneficiary or owner not correctly registered");
        WillToken(willTokenAddress).safeTransferFrom(owner, beneficiary, _tokenId, "");
    }

    function getRealTokenAddress()public view returns(address){
        return realTokenAddress;
    }

    function setRealTokenAddress(address _realTokenAddress) external onlyController{
        realTokenAddress = _realTokenAddress;
    }
    
    function getwillTokenAddress()public view returns(address){
        return willTokenAddress;
    }

    function setwillTokenAddress(address _willTokenAddress) external onlyController{
        willTokenAddress = _willTokenAddress;
    }
}