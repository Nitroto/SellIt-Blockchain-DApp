pragma solidity ^0.4.14;

contract Owned {
    address owner;

    modifier onlyowner() {
        if (msg.sender == owner) {
            _;
        }
    }

    function Owned() public {
        owner = msg.sender;
    }
}
