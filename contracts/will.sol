// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Will is AccessControl {
    string internal name;
    string internal description;
    uint256 internal tokenId;
    address internal owner;
    address internal beneficiary ;

    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 private constant BENEFICIARY_ROLE = keccak256("BENEFICIARY_ROLE");
    
    constructor(
        address _owner,
        string memory _name ,
        string memory _description,
        uint256  _tokenId
    ) {
        name = _name;
        description = _description;
        tokenId = _tokenId;
        owner =_owner;
        _grantRole(OWNER_ROLE,_owner);
        _grantRole(BENEFICIARY_ROLE,_owner);
    }

    event Receive(uint256);
    event DepositBalance( uint256 amount);
    event WithdrewBalance(address token, address by, address to, uint256 amount);

    function setBeneficiary(address _beneficiary) external onlyRole(OWNER_ROLE){
        beneficiary = _beneficiary;
        _grantRole(BENEFICIARY_ROLE,_beneficiary);
    }

    function getBeneficiary()public view returns(address){
        return beneficiary;
    }

    function getOwner()public view returns(address){
        return owner;
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function depositBalance()external payable onlyRole(OWNER_ROLE){
        emit DepositBalance(msg.value);
    }

    function withdrawBalance(address _tokenAddress,address _to ,uint256 _amount) external onlyRole(BENEFICIARY_ROLE) {
        IERC20Metadata token = IERC20Metadata(_tokenAddress);
        // get balace of token
        uint256 balance = token.balanceOf(address(this));
        require(balance >= _amount, "Not Enought Balance !");
        token.transfer(_to, _amount);
        emit WithdrewBalance(_tokenAddress, msg.sender, _to, _amount);
    }

    receive() external payable {
        // React to receiving ether
        emit Receive(msg.value);
    }
}