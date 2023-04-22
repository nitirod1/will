//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "./WillToken.sol";
import "./Will.sol";

contract WillFactory {
    address internal CONTROLLER;
    address internal willToken;

    //address owner of will willowners[1] = contract is 2
    // willowners[1] = contract 2 ....
    // contract -> contract จัดการพินัยกรรม 
    mapping(address => address[]) public willOwners;
    //will address is token id
    mapping(address => uint256) tokenIdOfWill;
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

    function getWillOnwer()public view returns(address[] memory) {
        return willOwners[msg.sender];
    }

    function registerIDCard(uint256 _idCard) external {
        idCards[msg.sender] = _idCard;
        emit RegisterIdCard(msg.sender, _idCard);
    }

    function getIDCard(address _owner) external view returns (uint256) {
        return idCards[_owner];
    }

    function createWill(
        string memory _name,
        string memory _description
    ) external {
        require(idCards[msg.sender] != 0, "You must register ID card first.");
        require(willToken != address(0),"address will token unset now !");
        Will will = new Will(msg.sender ,willToken, _name, _description);
        uint256 tokendId= WillToken(willToken).mint(msg.sender, address(will));
        tokenIdOfWill[address(will)] = tokendId;
        willOwners[msg.sender].push(address(will));
    }

    function claimWill(address _willContract )external onlyController{
        address beneficiary = Will(_willContract).getBeneficiary();
        address owner = Will(_willContract).getOwner();
        require(beneficiary != address(0)  && owner!=address(0),"address beneficiary or owner not correctly registered");
        IERC721(willToken).safeTransferFrom(owner, beneficiary, tokenIdOfWill[_willContract], "");
    }

    function setWillToken(address _willToken) external onlyController{
        willToken = _willToken;
    }
}