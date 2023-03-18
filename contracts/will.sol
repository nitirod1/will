// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./factoryAsset.sol";

interface AssetContract{
    function newRealAsset(string memory _title,string memory _typeAsset,string memory _fileHash,address _owner)external;
    function newDigitalAsset(uint256 _id,string memory _title,uint256 _balance,address _owner)external;
    function getDigitalAssets(address _owner)external view returns (string memory,uint256) ;
    function deleteDigitalAsset(address _owner , uint256 _delBalance) external;
    // function getRealAsset(address _owner) public view ;
}

contract Will is ERC1155, AccessControl, Pausable, ERC1155Supply {
    AssetContract internal asset;
    uint256 public cost = 1 gwei;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // name of will
    string internal name;

    // store address to active flag will
    mapping(address => bool) active;
    
    // store token_id to address 
    mapping(uint256 => address) will;

    // construct connect with address asset 
    constructor(address _addr)
        ERC1155("ipfs://QmbJWAESqCsf4RFCqEY7jecCashj8usXiyDNfKtZCwwzGb")
    {   
        asset = AssetContract(_addr);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    modifier isActive(){
        require(active[msg.sender] == true );
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

    function deposit(uint256 _id)external payable{
        require(msg.value >= 0 ether,"Wrong ! Not enoght money");
        asset.newDigitalAsset( _id,"",msg.value,msg.sender);
    }

    function withdrawDigital(address from, address to) external isActive{
        require(active[msg.sender] ,"Will not active now ");
        (string memory _title,uint256 balance) = asset.getDigitalAssets(from);

        require(balance >= 0 ether , "didn't have ether in asset");
        asset.deleteDigitalAsset(msg.sender,balance); 
        payable(to).transfer(balance);
    }

    function mintWill( uint256 _id , uint256 _amount)
        public
    {
        require(_amount >= 0,"Wrong ! Amount");
        _mint(msg.sender, _id, _amount, "");
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

    function activeWill(address _adr) external onlyRole(OWNER_ROLE){
        active[_adr] = true;
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