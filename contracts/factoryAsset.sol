// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract FactoryAsset{
    struct DigitalAsset{
        uint256 id;
        string  title;
        uint256 balance;
    }

    struct RealAsset{
        string title;
        string typeAsset;
        string fileHash;
        address owner;
    }

    // address of the owner
    address internal admin;

    mapping(address => RealAsset[]) internal realAssets;
    mapping(address => DigitalAsset) internal digitalAssets;

    constructor(){
        admin = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == admin, "Not admin");
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

    function newDigitalAsset(uint256 _id ,string memory _title,
        uint256 _balance,
        address _owner)
        external{
            DigitalAsset memory asset = DigitalAsset({
                id:_id,
                title: _title,
                balance: _balance
        });
            digitalAssets[_owner] = asset;
        }
    
    function getRealAsset(address _owner) public view returns (RealAsset[] memory){
        return realAssets[_owner];
    }

    // function getDigitalAssets(address _owner) public view returns (string[] memory,uint256[] memory){
    //     uint256 size = digitalAssets[_owner].length;
    //     string[] memory tiltle = new string[](digitalAssets[_owner].length);
    //     uint256[] memory balance = new uint256[](digitalAssets[_owner].length);
    //     for(uint i =0;i<size;i++){
    //         DigitalAsset storage digitalAsset =digitalAssets[_owner][i];
    //         tiltle[i] = digitalAsset.title;
    //         balance[i] = digitalAsset.balance;
    //     }
    //     return (tiltle,balance);
    // }

    // function getTokenIDs(address _ownder)public view returns(uint256[] memory){
    //     return tokenIDs[_ownder];
    // }

    function getDigitalAssets(address _owner)public view returns (uint256,string memory,uint256) {
        return (digitalAssets[_owner].id,digitalAssets[_owner].title , digitalAssets[_owner].balance);
    }

    function delBalance(address _owner , uint256 _delBalance) external {
        digitalAssets[_owner].balance = digitalAssets[_owner].balance - _delBalance;
    }
    
    function delDigitalAsset(string memory _id , address _owner)external{
        
    }

    // function getCountDigtalAsset(address _owner)public view returns (uint256){
    //     return digitalAssets[_owner].length;
    // }

    function getCountRealAsset(address _owner)public view returns (uint256){
        return realAssets[_owner].length;
    }
}