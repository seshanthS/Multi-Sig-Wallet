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
    //txid, amount;
    mapping (uint => uint) txAmount;
    
    struct transaction {
        uint id;
        uint amount;
        address _to;
        address _from;
        string status;
        string data;
    }
    
    event approvalNeeded(uint _txId, address _from, address _to, uint _amount, string _data);
    event transactionComplete(uint _txId);
    event gotRequiredSignatures(uint _txId);
    
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
    
    function transfer(address _to, string _data) public onlyAllowedOwners payable {
        uint txId;
        //for testing, lets increment txid automatically by 1;
        txId ++;
        //TODO : assign txHash
        idToaddress[txId] = _to;
        uint amount;
        amount = msg.value;
        txAmount[txId] = amount;
        requestApproval(txId, msg.sender, _to, _data);
    }
    
    function _transfer(address _to,uint _amount, uint _txId) internal {
        address(_to).transfer(_amount);
        emit transactionComplete(_txId);
    }
    
    function requestApproval(uint _txId, address _from, address _to, string _data) private {
       uint _amount = txAmount[_txId];
        emit approvalNeeded(_txId, _from, _to, _amount, _data);
    }
    
    function approve(uint _txId) public onlyAllowedOwners {
        approval[_txId] +=1 ;
        uint amount = txAmount[_txId];
        if ( approval[_txId] >= minNeeded ) {
            emit gotRequiredSignatures(_txId);
            _transfer(idToaddress[_txId], amount, _txId);
        }
    }
}
