// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./will.sol";

contract willFactory{
    mapping(address => address[])public wills;
    

    function getWill(address _owner) public view returns(address [] memory){
        return wills[_owner];
    }

    event NewWill(address locker, address owner);

    function newWill(
        string memory _name,
    address _owner , 
    address _beneficiary 
    )public{
        // create new will
        Will will = new Will(_name,_owner,_beneficiary);

        wills[_owner].push(address(will));

        // emit new will event
        emit NewWill(address(will), _owner);
    }
} 