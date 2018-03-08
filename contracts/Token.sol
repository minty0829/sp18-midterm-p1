pragma solidity ^0.4.15;

import './interfaces/ERC20Interface.sol';
import './utils/SafeMath.sol';

/**
 * @title Token
 * @dev Contract that implements ERC20 token standard
 * Is deployed by `Crowdsale.sol`, keeps track of balances, etc.
 */

contract Token is ERC20Interface {
	using SafeMath for uint256;

    string public name = "PobyCoin";
    string public symbol = "PBC";

    uint256 private totalSupply = 5000;


    // uint256 public startTimestamp; // timestamp after which ICO will start
    // uint256 public durationSeconds = 3 weeks; // 4 weeks

	//maps from address to the allowMap, which contains the address and the amount allowed
    mapping (address => mapping (address => uint256)) internal allowed;	    								
    mapping (address => uint256) internal balance;

    address owner;

    function Token(uint256 initSupply) public {
    	owner = msg.sender;
        totalSupply = initSupply;
        balance[owner] = initSupply;
    }

    function addTotalSupply(uint256 _value) {
        require(msg.sender == owner);
        totalSupply = totalSupply.add(_value);
        balance[owner] = balance[owner].add(_value);
    }

    function reduceTotalSupply(uint256 _value) {
        require(msg.sender == owner);
        totalSupply = totalSupply.sub(_value);
        balance[owner] = balance[owner].sub(_value);
    }

    function getTotalSupply() constant returns (uint256 _value) {
        return totalSupply;
    }

	/// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256) {
    	require(_owner != address(0));
    	return balance[_owner];
    }

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {
    	require(_to != address(0));
    	require(balance[msg.sender] >= _value);
    	balance[msg.sender].sub(_value);
    	balance[_to].add(_value);
    	Transfer(msg.sender, _to, _value);

    	return true;
    }

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
    		require(_from != address(0));
    		require(_to != address(0));
    		require(allowed[_from][_to] >= _value);
    		require(balance[_from] >= _value);
    		allowed[_from][_to].sub(_value);
    		balance[_from].sub(_value);
    		balance[_to].add(_value);
    		Transfer(_from, _to, _value);

    		return true;
    }	


    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {
    	require(_spender != address(0));
    	allowed[msg.sender][_spender] = _value;
    	Approval(msg.sender, _spender, _value);

    	return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    	return allowed[_owner][_spender];
    }

    function burn(uint256 _value) {
    	require(balance[msg.sender] >= _value);
    	balance[msg.sender] = balance[msg.sender].sub(_value);
    	totalSupply = totalSupply.sub(_value);
    }

    function() public payable { 
    	revert();
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _burner, address indexed _value);
}

