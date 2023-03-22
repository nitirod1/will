// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Will is ERC721, Ownable {
    string internal name;
    address internal beneficiary ;
    string internal uri;
    bool internal active;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => uint256[]) digitalAssetId;
    mapping(address => uint256[]) realAssetId;

    constructor(
        string memory _name,
        address _beneficiary 
    ) ERC721("King MongKut's University", "KMUTT") {
        name = _name;
        beneficiary = _beneficiary;
        active = false;
    }

    modifier isActive(){
        require(active == true , "Not active");
        _;
    }

    function safeMint(address to,uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function activeWill() public onlyOwner{
        active = true;
    }

     function withdrawERC20(
        address _tokenAddress,
        uint256 _amount
    ) external isActive {
        IERC20Metadata token = IERC20Metadata(_tokenAddress);

        uint256 balance = token.balanceOf(address(this));

        require(balance >= _amount, "Not Enought Balance !");

        token.transfer(beneficiary, _amount);

    }

}