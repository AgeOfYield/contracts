// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./HeroBalance.sol";

contract UseHeroBalance {
  HeroBalance heroBalance;

  function _setHeroBalanceAddress(address contractAddress) internal {
    heroBalance = HeroBalance(contractAddress);
  }
}
