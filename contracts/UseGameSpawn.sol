// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./GameSpawn.sol";

contract UseGameSpawn {
  GameSpawn gameSpawn;

  function _setGameSpawnAddress(address contractAddress) internal {
    gameSpawn = GameSpawn(contractAddress);
  }
}
