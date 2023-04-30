//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "./WillToken.sol";
import "./Will.sol";

contract WillFactory {
    address internal CONTROLLER;
    address internal willToken;
    address internal realToken;

    mapping(address => address[]) public willOwners;
    mapping(address => uint256) tokendIdOfWill;
    mapping(address => uint256) public idCards;

    event CreateWill(address _will, address _owner);
    event RegisterIdCard(address _owner, uint256 _idCard);

    constructor() {
        CONTROLLER = msg.sender;
    }

    modifier onlyController{
        require(msg.sender == CONTROLLER, "you are not controller ");
        _;
    }

    function getTokendIdOfWill(address _will) public view returns(uint256) {
        return tokendIdOfWill[_will];
    }

    function getWillOnwer(address _owner)public view returns(address[] memory) {
        return willOwners[_owner];
    }

    function registerIDCard(uint256 _idCard) external {
        idCards[msg.sender] = _idCard;
        emit RegisterIdCard(msg.sender, _idCard);
    }

    function getIDCard(address _owner) external view returns (uint256) {
        return idCards[_owner];
    }

    // createwil -> mint nft -> approve will contract -> metamask approved 
    function createWill(
        string memory _name,
        string memory _description
    ) external {
        require(idCards[msg.sender] != 0, "You must register ID card first.");
        require(willToken != address(0),"address will token unset now !");
        Will will = new Will(msg.sender , willToken , realToken, _name, _description);
        uint256 tokendId = WillToken(willToken).mintWill(address(will));
        tokendIdOfWill[address(will)] = tokendId;
        willOwners[msg.sender].push(address(will));
    }

    function claimWill(address _willContract )external{
        address beneficiary = Will(_willContract).getBeneficiary();
        address owner = Will(_willContract).getOwner();
        require(beneficiary != address(0)  && owner!=address(0),"address beneficiary or owner not correctly registered");
        WillToken(willToken).safeTransferFrom(owner, beneficiary, tokendIdOfWill[_willContract], "");
    }

    function setRealToken(address _realToken) external onlyController{
        realToken = _realToken;
    }

    function setWillToken(address _willToken) external onlyController{
        willToken = _willToken;
    }
}