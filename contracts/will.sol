// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./factoryAsset.sol";

contract Will is ERC1155, AccessControl, Pausable, ERC1155Supply {
    FactoryAsset public asset;
    bool public active = false;
    uint256 public cost = 1 gwei;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor(address _addr)
        ERC1155("ipfs://QmbJWAESqCsf4RFCqEY7jecCashj8usXiyDNfKtZCwwzGb")
    {   
        asset = FactoryAsset(_addr);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    modifier isActive(){
        require(active == true );
        _;
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mintDigital( uint256 id, uint256 _balance)
        public
        payable
    {
        require(_balance == msg.value,"Wrong ! Not enoght money");
        asset.newDigitalAsset("",_balance,"",msg.sender);
        _mint(msg.sender, id, _balance, "");
    }

    function withdraw(address _addr) external isActive{
        require(active ,"Will not active now ");

        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    function uri(uint256 _id)public view virtual override returns(string memory ){
        require(exists(_id),"URI: nonexistent token");

        return string(abi.encodePacked(super.uri(_id),Strings.toString(_id),".json"));
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(OWNER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    function activeWill() external onlyRole(OWNER_ROLE){
        active = true;
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    
}