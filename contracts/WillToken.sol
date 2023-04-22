//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract WillToken is ERC721, ERC721Burnable, AccessControl  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    bytes32 internal constant Controller = keccak256("Controller");

    string public baseURI;

    string internal baseExtension = ".json";

    constructor(address _willFactory) ERC721("Will Token", "WILL") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Controller, _willFactory);
    }

    function mint(address _to,address _contract) external onlyRole(Controller) returns(uint256)  {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        setApprovalForAll(_contract, true);
        return tokenId;
    }

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

    function setBaseURI(
        string memory _newBaseURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}