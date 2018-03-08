pragma solidity ^0.4.15;

import './Queue.sol';
import './Token.sol';

/**
 * @title Crowdsale
 * @dev Contract that deploys `Token.sol`
 * Is timelocked, manages buyer queue, updates balances on `Token.sol`
 */

contract Crowdsale {
	using SafeMath for uint256;
	// YOUR CODE HERE

	address owner;
	Token t;
	uint256 fundRaised;
	uint256 totalSold;
	uint256 startTime;
	uint256 endTime;
	uint256 value; //specifies how many PobyCoin equals 1 wei
	Queue q;

	function Crowdsale(uint256 startSupply) {
		owner = msg.sender;
		t = Token(startSupply);
		fundRaised = 0;
		totalSold = 0;
	}

	modifier isOwner() {
		if (msg.sender == owner) {
			_;
		}
	}

	modifier goodHour() {
		if (startTime <= now && now <= endTime) {
			_;
		}
	}

	modifier goodQueue() {
		if (msg.sender == q.getFirst() && q.qsize() > 1) {
			_;
		}
	}

	function setTimeCap(uint256 _startTime, uint256 _endTime) isOwner() {
		startTime = _startTime;
		endTime = _endTime;
	}

	function setValue(uint256 _value) isOwner() {
		value = _value;
	}

	function mintCoin(uint256 _value) isOwner() {
		t.addTotalSupply(_value);
	}

	function burnCoin(uint256 _value) isOwner() {
		require(t.getTotalSupply() - totalSold >= _value);
		t.reduceTotalSupply(t.getTotalSupply() - _value);
	}

	function collectFund() isOwner() {
		require(fundRaised > 0);
		require(now > endTime);
		uint256 amount = fundRaised;
		fundRaised = 0;
		owner.transfer(amount);
	}

	function getInLine() goodHour() {
		q.enqueue(msg.sender);
	}

	function buyToken() payable goodHour() goodQueue() {
		uint256 amount = msg.value.mul(value);
		fundRaised = fundRaised.add(msg.value);
		totalSold = totalSold.add(amount);
		t.transferFrom(owner, msg.sender, amount);
		q.dequeue();
		Purchase(msg.sender, amount);
	}

	function refund(uint256 _value) goodHour() {
		uint256 amount = _value.div(value);
		t.transfer(owner, _value);
		totalSold = totalSold.sub(_value);
		msg.sender.transfer(amount);
		Refund(msg.sender, _value);
	}

	event Purchase(address _buyer, uint256 _value);
	event Refund(address _requester, uint256 _value);
}
