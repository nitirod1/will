// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IERC20MetaData.sol";
import "./RealToken.sol";
import "./WillToken.sol";

contract Will {
    string internal name;
    string internal description;
    uint256[] internal realTokenId;
    address internal owner;
    address internal beneficiary;
    address internal realToken;
    address internal willToken;

    mapping(address => uint256) balance;

    constructor(
        address _owner,
        address _willToken,
        address _realToken,
        string memory _name,
        string memory _description 
    ) {
        willToken = _willToken;
        realToken =_realToken;
        name = _name;
        description = _description;
        owner = _owner;
    }

    event Receive(uint256);
    event DepositBalance(address tokenAddress , uint256 amount);
    event DepositRealAsset(address tokenAddress, address contractStorag);
    event WithdrewBalance(
        address token,
        address by,
        address to,
        uint256 amount
    );

    modifier allowAssets{
        require(msg.sender == owner || msg.sender == beneficiary, "you can't allow this asset ");
        _;
    }

    modifier onlyOwner{
        require(msg.sender == owner ,"you are not owenr");
        _;
    }

    modifier onlyBeneficiary{
        require(msg.sender == beneficiary , "you are not beneficiary");
        _;
    }

    function getBalance(address _tokenAddress) public view returns(uint256){
        return balance[_tokenAddress];
    }

    function getRealTokenId()public view returns(uint256[] memory){
        return realTokenId;
    }

    function getRealTokenAddress() public view returns(address){
        return realToken;
    }

    function getBeneficiary()public view returns(address){
        return beneficiary;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setBeneficiary(address _beneficiary) external onlyOwner{
        beneficiary =_beneficiary;
    }

    function depositRealAsset()external onlyOwner{
        uint256 tokenId = RealToken(realToken).mint(msg.sender);
        realTokenId.push(tokenId);
    }

    function withdrawRealAsset(uint256 _tokenId,uint256 _willTokenId)external allowAssets{
        address ownerWill  = WillToken(willToken).ownerOf(_willTokenId);
        require( msg.sender == ownerWill , "will token not active" );
        require(beneficiary != address(0)  && owner!=address(0),"address beneficiary or owner not correctly registered");
        RealToken(realToken).safeTransferFrom(owner, beneficiary, _tokenId);
    }

    function depositBalance(
        address _tokenAddress , 
        uint256 _amount 
        ) external payable onlyOwner {
        IERC20MetaData token = IERC20MetaData(_tokenAddress);
        uint256 value =  token.balanceOf(msg.sender);
        require(value >= _amount, "balance not enough ");
        token.transferFrom(msg.sender ,address(this),_amount);
        balance[_tokenAddress] = balance[_tokenAddress] + _amount;
        emit DepositBalance(msg.sender,_amount);
    }

    function withdrawBalance(
        address _tokenAddress,
        uint256 _amount,
        uint256 _willTokenId
    ) external allowAssets {
        // check nft this tokenid 
        // mint nft -> token , contract can mange token -> approve(spender , tokenid ) for erc 721 this contract
        address ownerWill  = WillToken(willToken).ownerOf(_willTokenId);
        require( msg.sender == ownerWill , "will token not active" );
        IERC20MetaData token = IERC20MetaData(_tokenAddress);
        require(token.balanceOf(address(this)) >= _amount, "balance must be positive");
        token.transfer(beneficiary,_amount);
        emit WithdrewBalance(_tokenAddress, address(this), beneficiary, _amount);
    }

}