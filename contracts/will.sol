// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IERC20MetaData.sol";
import "./interfaces/IRealToken.sol";


contract Will is AccessControl {
    string internal name;
    string internal description;
    address internal owner;
    address internal uriRealToken;
    // address of beneficiary to real asset token id address(beneficiary) = array tokenid [1, 5, 6]
    mapping(address => uint256[])internal claim;
    // address of beneficiary to token address 
    mapping(address => mapping(address => uint256)) balance;
    // address of token address to remaining balance
    mapping(address => uint256)remaining;

    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 private constant BENEFICIARY_ROLE = keccak256("BENEFICIARY_ROLE");

    constructor(
        address _owner,
        string memory _name,
        string memory _description // uint256 _tokenId
    ) {
        name = _name;
        description = _description;
        owner = _owner;
        _grantRole(OWNER_ROLE, _owner);
        _grantRole(BENEFICIARY_ROLE, _owner);
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

    function getOwner() public view returns (address) {
        return owner;
    }

    function getBalance(address _tokenAddress) public view returns (uint256) {
        return IERC20MetaData(_tokenAddress).balanceOf(address(this));
    }

    function depositBalance(
        address _tokenAddress , 
        uint256 _amount 
        ) external payable onlyRole(OWNER_ROLE) {
        IERC20MetaData token = IERC20MetaData(_tokenAddress);
        uint256 value =  token.balanceOf(msg.sender);
        require(value >= _amount, "balance not enough ");
        token.transferFrom(msg.sender ,address(this),_amount);
        // เหมือนฝากเงิน usd , yen , russian , ...
        // remaining[usd] = มีเท่าไหร่ในคอนแท็ค
        remaining[_tokenAddress] = remaining[_tokenAddress] + _amount;
        emit DepositBalance(msg.sender,_amount);
    }

    function manageDigital(
        address _tokenAddress , 
        uint256 _amount ,
        address _beneficiary
        )external onlyRole(OWNER_ROLE){
        // usd 10 บาท mannage usd 5 bath = 5 บาท
        require(remaining[_tokenAddress] >= _amount, "balance not enough ");
        remaining[_tokenAddress] = remaining[_tokenAddress] - _amount;
        // balance[ผู้รับ][token]= จะได้เงินเท่าไหร่
        balance[_beneficiary][_tokenAddress] = _amount;
    }

    // usd = tokenaddress , eth chain 
    function claimDigital(address _tokena)external onlyRole(BENEFICIARY_ROLE){
        require(balance[msg.sender][]);
    }

    function chcekClaimRealAsset() public view returns(uint256[] memory){
        return claim[msg.sender];
    }

    function withdrawBalance(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external onlyRole(BENEFICIARY_ROLE) {
        //edit
        IERC20MetaData token = IERC20MetaData(_tokenAddress);
        require(token.balanceOf(address(this)) >= _amount, "balance must be positive");
        token.transfer(_to,_amount);
        emit WithdrewBalance(_tokenAddress, address(this), _to, _amount);
    }

    receive() external payable {
        // React to receiving ether
        emit Receive(msg.value);
    }

    function setURIRealToken(address _uriRealToken) external onlyRole(OWNER_ROLE) {
        uriRealToken = _uriRealToken;
    }
}