// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./will.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract willFactory is ERC721, AccessControl {
    // owner of will
    mapping(address => address) public owner;
    // status of will
    mapping(address => bool) public wills;
    // tokenId of will
    mapping(uint256 => address) public tokenIds;

    mapping(address => uint256) public idCards;

    address private activeWallet = 0x37613520fe0207B701f990F4634bfd0F08A90e78 ;

    string public baseURI;

    string internal baseExtension = ".json";

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    bytes32 private constant ACTIVE_ROLE = keccak256("ACTIVE_ROLE");

    constructor() ERC721("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
        _grantRole(ACTIVE_ROLE,activeWallet);
    }

    function registerIdCard(uint256 _idCard)external {
        idCards[msg.sender] = _idCard;
    }

    function getIdCard()public view returns(uint256){
        return idCards[msg.sender];
    }

    function setStatusWill(address _adrWill)external onlyRole(ACTIVE_ROLE){
        wills[_adrWill] = true;
    }

    function getStatusWill(address _adrWill ) public view returns(bool){
        return wills[_adrWill];
    }

    function getOwner(address _adrWill) public view returns(address){
        return owner[_adrWill];
    }

    function safeMint(address to ,string memory _name ) public payable{
        require(msg.value >=0 , "balance not enough");
        uint256 tokenId = _tokenIdCounter.current();
        Will will = new Will(_name,idCards[to],tokenId,to , msg.value );
        owner[address(will)] = to;
        wills[address(will)] = false;
        tokenIds[tokenId] = address(will);
        _safeMint(to, tokenId);
        _grantRole(OWNER_ROLE,msg.sender);
        _tokenIdCounter.increment();
    }

    function inheritWill(address from, address to, uint256 tokenId,address _adrWill) external {
        require(wills[_adrWill] == true , "will not active now");
        transferFrom(from,to,tokenId);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "Subtawee: not exist");
        string memory currentBaseURI = _baseURI();
        return (
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(_tokenId),
                        baseExtension
                    )
                )
                : ""
        );
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}