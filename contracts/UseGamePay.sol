// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./GamePay.sol";

contract UseGamePay {
  GamePay gamePay;

  function _setGamePayAddress(address contractAddress) internal {
    gamePay = GamePay(contractAddress);
  }
}
