pragma solidity ^0.8.0;

contract Thor{
    string  public name = "Thoritos";
    string  public symbol = "THOR";
    uint256 public totalSupply = 100000000000000; // 100,000
    uint8   public decimals = 8;
    address owner;
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    
    // Stores the data related to locking
    struct TimeLock{
        uint _amount;
        uint _releaseTime;
    }
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) private allowance;
    mapping(address => TimeLock) lockData;

    constructor() {
        owner= msg.sender;
        balances[owner] = totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "ERC20: approve to the zero address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    // minted tokens will go to the owner only
    function _mint(uint256 amount) internal {
        require(msg.sender==owner, "Owner calls mint");

        totalSupply += amount;
        balances[owner] += amount;
        emit Transfer(address(0), owner, amount);
    }
    // Only owner burns the tokens (I can make a modifier too, but it's not a big contract)
    function burn(uint256 amount) internal{
        require(msg.sender==owner, "owner calls burn");
        uint256 accountBalance= balances[owner];
        require(accountBalance<amount, "burning amount exceeds balance");
        balances[owner]= accountBalance-amount;
        accountBalance=0;
        totalSupply-=amount;
        emit Transfer(owner,address(0), amount);
    }
    // simple lock function in the same contract (Openzeppelin has already made a contract for this)
    function lock(uint releaseTime, uint amount) public{
        require(amount>balances[msg.sender], "amount can't be greater than balance");
        require(releaseTime<block.timestamp, "release time must be future");
        lockData[msg.sender]= TimeLock(amount, releaseTime);
        // lock
        balances[msg.sender]-=amount;
        // EVENT
    }
    function release() public{
        require(lockData[msg.sender]._releaseTime<block.timestamp, "Time hasn't come yet");
        uint amount= lockData[msg.sender]._amount;
        lockData[msg.sender]._amount=0;
        lockData[msg.sender]._releaseTime=0;
        // release
        balances[msg.sender]+=amount;
        // EVENT
    }
}
