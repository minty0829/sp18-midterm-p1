pragma solidity ^0.4.15;

import './utils/SafeMath.sol';
/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {
	using SafeMath for *;
	/* State variables */
	address[] queue;
	uint8 cap = 5;
	uint8 curLen;
	uint8 front; //index of front of the line, ie where purchase can be made if person behind
	uint8 back;	//index of back of the line, ie where a newcomer would be at

	// YOUR CODE HERE

	uint256 public maxStallTime;
	uint256 public startTime;
	uint256 public curTime;

	/* Add events */
	event Eject(address indexed _ejected);

	/* Add constructor */
	function Queue() {
		curLen = 0;
		front = 0;
		back = 0;
	}

	/* Returns the number of people waiting in line */
	function qsize() constant returns(uint8) {
		return curLen;
	}

	/* Returns whether the queue is empty or not */
	function empty() constant returns(bool) {
		return curLen <= 0;
	}
	
	/* Returns the address of the person in the front of the queue */
	function getFirst() constant returns(address) {
		return queue[front];
	}
	
	/* Allows `msg.sender` to check their position in the queue */
	function checkPlace() constant returns(uint8) {
		for (uint8 i = 0; i < cap; i++) {
			if (queue[i] == msg.sender) {
				return (i - front) % cap;
			}
		}
		revert();
	}
	
	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() {
		curTime = now;
		if (curTime - startTime >= maxStallTime) {
			dequeue();
		}
	}
	
	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase
	 */
	function dequeue() {
		require(curLen > 0);
		queue[front] = 0;
		curLen = curLen.sub(1);
		front = front.add(1) % cap;
		startTime = now;
		if (curTime - startTime >= maxStallTime) {
			Eject(queue[front]);
		}
	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address addr) {
		require(curLen < cap);
		if (empty()) {
			startTime = now;
		}
		queue[back] = addr;
		back = back.add(1) % cap;
		curLen = curLen.add(1);
	}

	function() payable {
		revert();
	}
}
