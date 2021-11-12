// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./GameHeroStamina.sol";

contract UseGameHeroStamina {
  GameHeroStamina gameHeroStamina;

  function _setGameHeroStaminaAddress(address contractAddress) internal {
    gameHeroStamina = GameHeroStamina(contractAddress);
  }
}
