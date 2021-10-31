// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./GameHeroCoordinates.sol";

contract UseGameHeroCoordinates {
  GameHeroCoordinates gameHeroCoordinates;

  function _setGameHeroCoordinatesAddress(address contractAddress) internal {
    gameHeroCoordinates = GameHeroCoordinates(contractAddress);
  }
}
