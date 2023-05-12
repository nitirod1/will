//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "./WillToken.sol";
import "./RealToken.sol";
import "./Will.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract WillFactory is AccessControl{
    address internal CONTROLLER;
    address internal willTokenAddress;
    address internal realTokenAddress;

    bytes32 private constant Controller = keccak256("Controller");

    mapping(uint256 => address) register;
    mapping(address => uint256[]) internal tokenIdOwner;
    mapping(uint256 => address) internal tokendIdOfWill;

    event CreateWill(address _will, address _owner);
    event RegisterIdCard(address _owner, uint256 _idCard);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Controller, msg.sender);
    }

    function registerID(uint256 _id, address _to) external {
        register[_id] = _to;
    }

    function getRegister(uint256 _id)public view returns(address){
        return register[_id];
    }

    function getTokendIdOfWill(uint256 _tokendId) public view returns(address) {
        return tokendIdOfWill[_tokendId];
    }

    function getTokenIdOnwer(address _owner)public view returns(uint256[] memory) {
        return tokenIdOwner[_owner];
    }

    function createWill(
        string memory _name,
        string memory _description,
        string memory _uri
    ) external {
        require(willTokenAddress != address(0),"address will token unset now !");
        uint256 tokenId = WillToken(willTokenAddress).mintWill(msg.sender,_uri);
        Will will = new Will(msg.sender , willTokenAddress , realTokenAddress,tokenId, _name, _description);
        RealToken(realTokenAddress).grantRoleContract(address(will));
        tokendIdOfWill[tokenId] = address(will);
        tokenIdOwner[msg.sender].push(tokenId);
    }

    function claimWill(address _willContract , uint256 _tokenId )external onlyRole(Controller){
        address beneficiary = Will(_willContract).getBeneficiary();
        address owner = Will(_willContract).getOwner();
        require(beneficiary != address(0)  && owner!=address(0),"address beneficiary or owner not correctly registered");
        WillToken(willTokenAddress).safeTransferFrom(owner, beneficiary, _tokenId, "");
    }

    function getRealTokenAddress()public view returns(address){
        return realTokenAddress;
    }

    function setRealTokenAddress(address _realTokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        realTokenAddress = _realTokenAddress;
    }

    function getwillTokenAddress()public view returns(address){
        return willTokenAddress;
    }

    function setwillTokenAddress(address _willTokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        willTokenAddress = _willTokenAddress;
    }
}