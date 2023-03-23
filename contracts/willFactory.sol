// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./will.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract willFactory is ERC721, AccessControl {
    // owner of will
    mapping(address => address) public owner;
    // status of will
    mapping(address => bool) public wills;
    // tokenId of will
    mapping(uint256 => address) public tokenIds;

    using Counters for Counters.Counter;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    Counters.Counter private _tokenIdCounter;
    
    constructor() ERC721("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    function getStatusWill(address _adrWill ) public view returns(bool){
        return wills[_adrWill];
    }

    function getOwner(address _adrWill) public view returns(address){
        return owner[_adrWill];
    }

    event NewWill(address locker, address owner);

    function newWill(
    uint256 _tokenId,
    address _owner , 
    address _beneficiary 
    )public onlyRole(OWNER_ROLE){
        // create new will
        Will will = new Will(_tokenId,_owner,_beneficiary);

        owner[address(will)] = _owner;

        wills[address(will)] = false;

        tokenIds[_tokenId] = address(will);

        // emit new will event
        emit NewWill(address(will), _owner);
    }

   function safeMint(address to) public onlyRole(OWNER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _tokenIdCounter.increment();
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}