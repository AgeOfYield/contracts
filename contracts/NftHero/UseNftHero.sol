// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./NftHero.sol";

contract UseNftHero {
  NftHero nftHero;

  function _setNftHeroAddress(address contractAddress) internal {
    nftHero = NftHero(contractAddress);
  }
}
