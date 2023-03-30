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
    // mapping address wallet contract to addess will contract
    mapping(address => address) public owner;

    // mapping address will contract to status will
    mapping(address => bool) public wills;

    // mapping address wallet to idcard
    mapping(address => uint256) public idCards;

    // address for permission active will on
    address private activeWallet = 0x37613520fe0207B701f990F4634bfd0F08A90e78 ;

    string public baseURI;

    string internal baseExtension = ".json";

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 private constant ACTIVE_ROLE = keccak256("ACTIVE_ROLE");

    constructor() ERC721("Will-Chain", "will") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ACTIVE_ROLE,activeWallet);
    }

    event NewWill(address will , address owner );
    event InheritWill(address contractWill,address by, address to, uint256 tokenId);

    function newWill(
        address _owner,
        string memory _name ,
        string memory _description
        ) external{
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(_owner, tokenId);
        Will will = new Will(_owner,_name , _description,tokenId  );
        owner[_owner] =  address(will);
        wills[address(will)] = false;
        _tokenIdCounter.increment();
        emit NewWill(address(will), _owner);
    }

    function registerIdCard(uint256 _idCard)external {
        idCards[msg.sender] = _idCard;
    }

    function getIdCard()public view returns(uint256){
        return idCards[msg.sender];
    }

    function getStatusWill(address _adrWill ) public view returns(bool){
        return wills[_adrWill];
    }

    function getWillContract(address _owner) public view returns(address){
        return owner[_owner];
    }

    function inheritWill(address from, address to, uint256 tokenId,address _adrWill) external {
        require(hasRole(ACTIVE_ROLE, msg.sender), "Caller is not Active role");
        wills[_adrWill] = true;
        transferFrom(from,to,tokenId);
        emit InheritWill(_adrWill,from,to,tokenId);
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