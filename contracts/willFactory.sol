//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "./interfaces/IWillToken.sol";
import "./Will.sol";

contract WillFactory {
    address internal OWNER;
    address internal willToken;

    //address owner of will willowners[1] = contract is 2
    // willowners[1] = contract 2 ....
    // contract -> contract จัดการพินัยกรรม 
    mapping(address => address[]) public willOwners;
    mapping(address => bool) public wills;
    mapping(address => uint256) public idCards;

    event CreateWill(address _will, address _owner);
    event RegisterIdCard(address _owner, uint256 _idCard);

    constructor() {
        OWNER = msg.sender;
    }

    function getWillOnwer(address _owner)public view returns(address[] memory) {
        return willOwners[msg.sender];
    }

    function registerIDCard(uint256 _idCard) external onlyOwner {
        idCards[msg.sender] = _idCard;
        emit RegisterIdCard(msg.sender, _idCard);
    }

    function getIDCard(address _owner) external view returns (uint256) {
        return idCards[_owner];
    }

    // create will 2 รอบ -> design 
    // manage asset -> manage asset -> manage asset ยังไงวะ
    function createWill(
        string memory _name,
        string memory _description
    ) external {
        require(idCards[msg.sender] != 0, "You must register ID card first.");
        Will will = new Will(msg.sender, _name, _description);
        willOwners[msg.sender].push(address(will));
    }

    function setWillToken(address _will_token) external onlyOwner {
        willToken = _will_token;
    }
}