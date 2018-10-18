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
    // NEW BRANCH >>
    struct transaction {
        uint8 signatureCount;
        uint id;
        uint amount;
        address _to;
        address _from;
        //0 -> pending or 1 -> completed(success/fail)
        uint8 status;
        string data;
        address[] signatures;
       
    }
    //txId, transaction
    mapping(uint  => transaction) tx;
    uint[] private transactionList;
    
     // NEW BRANCH -ENDS <<
     
     
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
    uint txId;
    function transfer(address _to, string _data) public onlyAllowedOwners payable {
       
        txId++;
        transaction memory t1;
        t1.id = txId;
        t1.amount = msg.value;
        t1._to = _to;
        t1._from = msg.sender;
        t1.status = 0;
        t1.data = _data;
        
        tx[txId] = t1;
        
        requestApproval(t1.id);
        /*
        uint txId;
        //for testing, lets increment txid automatically by 1;
        txId ++;
        //TODO : assign txHash
        idToaddress[txId] = _to;
        uint amount;
        amount = msg.value;
        txAmount[txId] = amount;
        requestApproval(txId, msg.sender, _to, _data);
        */
    }
    
    function _transfer(address _to,uint _amount, uint _txId) internal {
        transaction memory t1 = tx[_txId];
        require(t1.status != 1);
        t1.status = 1;
        address(_to).transfer(_amount);
        emit transactionComplete(_txId);
    }
    
    function requestApproval(uint _txId) private {
       transaction memory t1 = tx[_txId];
       emit approvalNeeded (t1.id, t1._from, t1._to, t1.amount, t1.data);
        //emit approvalNeeded(_txId, _from, _to, _amount, _data);
    }
    
    function approve(uint _txId) public onlyAllowedOwners {
        transaction storage t1 = tx[_txId];
        t1.signatureCount++;
        t1.signatures.push(msg.sender);
        if (t1.signatureCount >= minNeeded) {
            emit gotRequiredSignatures(_txId);
            _transfer(t1._to, t1.amount, t1.id);
        }
        /*
        approval[_txId] +=1 ;
        uint amount = txAmount[_txId];
        if ( approval[_txId] >= minNeeded ) {
            emit gotRequiredSignatures(_txId);
            _transfer(idToaddress[_txId], amount, _txId);
        }
        */
    }
}
