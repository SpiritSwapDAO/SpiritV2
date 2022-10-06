// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IhiBERO {
    function locked(address account) external view returns (uint128, uint256);
    function locked__end(address account) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function deposit_for(address account, uint256 amount) external;
}

contract LockDrop is Ownable {

    address public BERO;
    address public hiBERO;
    uint256 public minTime; // minimum lock time needed for user to claim
    uint256 public minAmount = 100000000000000000000;

    mapping(address => uint256) public balances; // BERO able to be claimed

    constructor(address _BERO, address _hiBERO, uint256 _minTime) {
        BERO = _BERO;
        hiBERO = _hiBERO;
        minTime = _minTime;
    }

    // takes in array of addresses and amounts
    // sets user balances
    function setBalances(address account, uint256 amount) external onlyOwner {
        balances[account] = amount;
    }

    // make nonreentrant
    function claim() external {
        address account = msg.sender;
        uint256 amount = IERC20(hiBERO).balanceOf(account);
        uint256 time = IhiBERO(hiBERO).locked__end(account);
        require(amount > minAmount && time > minTime, "!Eligible");
        uint256 balance = balances[account];
        balances[account] = 0;
        //IERC20(BERO).transfer(account, balance);
        IERC20(BERO).approve(hiBERO, balance);
        IhiBERO(hiBERO).deposit_for(account, balance);
        // emit claimed
    }

}