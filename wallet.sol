pragma solidity ^0.4.24;

contract wallet {
    
    uint8 minNeeded;
    address owner;
    mapping(address => uint)private allowedOwners;
    //transactionId, addresses_who_signed, signature_Status(1 or 0)
    mapping(uint => mapping (address => uint )) signatures;
    //txId, to address
    mapping(uint => address) idToaddress;
    //txId, no.of.Approvals;
    mapping(uint => uint8) private approval;
    
    event approvalNeeded(uint _txId, address _from, address _to, uint _amount, string _data);
    
    constructor() public payable {
        owner = msg.sender;
        allowedOwners[owner] = 1;
        minNeeded = 1;
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
    
    function transfer(address _to, uint _amount, string _data) public onlyAllowedOwners {
        uint txId;
        //for testing, lets increment txid automatically by 1;
        txId ++;
        //TODO : assign txHash
        idToaddress[txId] = _to;
        requestApproval(txId, msg.sender, _to, _amount, _data);
    }
    
    function _transfer(address _to) internal {
        address(_to).transfer(msg.value);
    }
    
    function requestApproval(uint _txId, address _from, address _to, uint _amount, string _data) private {
        emit approvalNeeded(_txId, _from, _to, _amount, _data);
    }
    
    function approve(uint _txId) public onlyAllowedOwners {
        approval[_txId] +=1 ;
        if ( approval[_txId] >= minNeeded ) {
            _transfer(idToaddress[_txId]);
        }
    }
}
