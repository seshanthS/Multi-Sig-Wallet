pragma solidity ^0.4.24;

contract wallet {
    address owner;
    mapping(address => uint)private allowedOwners;
    //transactionId, addresses_who_signed, signature_Status(1 or 0)
    mapping(uint => mapping (address => uint )) signatures;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyAllowedOwners {
        require(allowedOwners[msg.sender] == 1);
        _;
    }
    
    function addOwner(address _newOwner) public onlyAllowedOwners {
        allowedOwners[_newOwner] = 1;
    }
    
    function revokeOwner(address _oldOwner) public onlyAllowedOwners {
        allowedOwners[_oldOwner] = 0;
    }
    
    function balance() public view onlyAllowedOwners returns (uint) {
        return address(this).balance;
    }
    
    function() public payable {
        
    }
}
