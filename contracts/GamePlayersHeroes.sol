// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./lib/Math2d.sol";
import "./UseGameHeroCoordinates.sol";
import "./UseGameSpawn.sol";
import "./HeroBalance/UseHeroBalance.sol";
import "./NftHero/UseNftHero.sol";
import "./NftHero/abstract/HeroCharacteristics.sol";

contract GamePlayersHeroes is
  AccessControl,
  UseGameHeroCoordinates,
  UseGameSpawn,
  UseHeroBalance,
  UseNftHero
{
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  /**
    * @dev Grants `DEFAULT_ADMIN_ROLE`, `ADMIN_ROLE` to the account that
    * deploys the contract.
    */
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(ADMIN_ROLE, _msgSender());
  }

  function getHeroCharacteristics(uint256 tokenId) public view returns(HeroCharacteristics.Characteristics memory) {
    require(
      gameSpawn.ownerOf(tokenId) == _msgSender(),
      ""
    );
    
    return nftHero.getCharacteristics(tokenId);
  }

  function getCapacity(address tokenAddress, uint256 tokenId) public view returns(uint256) {
    require(
      gameSpawn.ownerOf(tokenId) == _msgSender(),
      ""
    );

    return heroBalance.getCapacity(tokenAddress, tokenId);
  }

  function balanceOf(address tokenAddress, uint256 tokenId) public view returns(uint256) {
    require(
      gameSpawn.ownerOf(tokenId) == _msgSender(),
      ""
    );

    return heroBalance.balanceOf(tokenAddress, tokenId);
  }

  function getCoordinates(uint256 tokenId) public view returns(Math2d.Point memory) {
    require(
      gameSpawn.ownerOf(tokenId) == _msgSender(),
      ""
    );

    return gameHeroCoordinates.getCoordinates(tokenId);
  }

  /**
    * @dev Set heroes coordinates contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGameHeroCoordinatesAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "Player: must have admin role to set address");

    _setGameHeroCoordinatesAddress(contractAddress);
  }

  /**
    * @dev Set spawn contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGameSpawnAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "Player: must have admin role to set address");

    _setGameSpawnAddress(contractAddress);
  }

  /**
    * @dev Set NFT Heroes contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setNftHeroAddress(address nftHeroAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "Player: must have admin role to set NFT Hero contract");

    _setNftHeroAddress(nftHeroAddress);
  }

  /**
    * @dev Set game hero balance contract address.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setHeroBalanceAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set contract address");

    _setHeroBalanceAddress(contractAddress);
  }
}