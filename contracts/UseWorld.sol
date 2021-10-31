// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./World.sol";

contract UseWorld {
  World world;

  function _setWorldAddress(address contractAddress) internal {
    world = World(contractAddress);
  }
}
