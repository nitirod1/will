//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract WillToken is ERC721,ERC721URIStorage, ERC721Burnable, AccessControl  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    bytes32 private constant Controller = keccak256("Controller");

    constructor(address _willFactory) ERC721("Will Token", "WILL") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Controller, _willFactory);
    }

    function mintWill(address _to,string memory uri) external onlyRole(Controller) returns(uint256)  {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override virtual onlyRole(Controller){}

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
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