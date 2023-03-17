// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract FactoryAsset{
    struct DigitalAsset{
        string  title;
        uint256 balance;
        string  typeToken;
        address owner;
    }

    struct RealAsset{
        string title;
        string typeAsset;
        string fileHash;
        address owner;
    }

    // address of the owner
    address public owner;

    // address of the beneficiary

    mapping(address => address[])public beneficiary;
    mapping(address => RealAsset[]) public realAssets;
    mapping(address => DigitalAsset[]) public digitalAssets;

    constructor(){
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // event NewDigitalAsset(DigitalAsset asset, address owner);
    // event NewRealAsset(address realAsset, address owner);

    function newRealAsset(string memory _title,
        string memory _typeAsset,
        string memory _fileHash,
        address _owner
        )external {
        RealAsset memory asset = RealAsset({
            title :_title,
            typeAsset :_typeAsset,
            fileHash : _fileHash,
            owner :_owner
        });
        realAssets[_owner].push(asset);
        }

    function newDigitalAsset(string memory _title,
        uint256 _balance,
        string memory _typeToken,
        address _owner)
        external{
            DigitalAsset memory asset = DigitalAsset({
            title: _title,
            balance: _balance,
            typeToken: _typeToken,
            owner: _owner
        });

        digitalAssets[_owner].push(asset);
        }
    
    function getRealAsset(address _owner) public view returns (RealAsset[] memory){
        return realAssets[_owner];
    }

    function getDigitalAsset(address _owner) public view returns (DigitalAsset[] memory){
        return digitalAssets[_owner];
    }

    function getCountDigtalAsset(address _owner)public view returns (uint256){
        return digitalAssets[_owner].length;
    }

    function getCountRealAsset(address _owner)public view returns (uint256){
        return realAssets[_owner].length;
    }
}