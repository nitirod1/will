//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

interface IWillToken {
    function mint(address _to) external;

    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function setBaseURI(string memory _newBaseURI) external;
}