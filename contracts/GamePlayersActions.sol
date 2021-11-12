// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./lib/Math2d.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./UseGameHeroCoordinates.sol";
import "./UseGameSpawn.sol";
import "./UseGamePay.sol";
import "./UseHeroBalance.sol";
import "./UseGameHeroStamina.sol";
import "./NftHero/UseNftHero.sol";

contract GamePlayersActions is
  Pausable,
  AccessControl,
  UseGameHeroCoordinates,
  UseGameSpawn,
  UseGamePay,
  UseNftHero,
  UseHeroBalance,
  UseGameHeroStamina
{
  using SafeMath for uint256;

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());

    _pause();
  }

  function calcStaminaByDistance(uint256 distance, uint256 aoyBoostAmount) internal pure returns(uint256) {
    (, uint256 stamina) = distance.div(10).trySub(aoyBoostAmount);

    return stamina;
  }

  function paymentAction(uint256 tokenId, uint256 amount, bool useHeroBalance) internal {
    if (amount != 0) {
      if (useHeroBalance) {
        heroBalance.reduceAoyBalance(tokenId, amount);
      } else {
        address tokenOwner = gameSpawn.ownerOf(tokenId);

        gamePay.payAoy(tokenOwner, amount);
      }
    }
  }

  function move(uint256 tokenId, Math2d.Point memory point, uint256 amount, bool useHeroBalance) public {
    require(!paused(), "GamePlayersActions: paused");
    address tokenOwner = gameSpawn.ownerOf(tokenId);
    require(tokenOwner == _msgSender());

    uint256 usedStamina = calcStaminaByDistance(
      gameHeroCoordinates.calcDistance(tokenId, point),
      amount
    );

    gameHeroStamina.spendStamina(tokenId, usedStamina);
    gameHeroCoordinates.setHeroCoordinates(tokenId, point);

    paymentAction(tokenId, amount, useHeroBalance);
  }

  function attack(uint256 tokenId, uint256 targetTokenId, uint256 amount, bool useHeroBalance) public returns(bool) {
    require(!paused(), "GamePlayersActions: paused");
    require(gameSpawn.ownerOf(tokenId) == _msgSender());

    Math2d.Point memory targetPoint = gameHeroCoordinates.getCoordinates(tokenId);

    uint256 usedStamina = calcStaminaByDistance(
      gameHeroCoordinates.calcDistance(tokenId, targetPoint),
      amount
    );

    gameHeroStamina.spendStamina(tokenId, usedStamina);

    uint256 heroFortune = nftHero.getFortune(tokenId);
    uint256 targetFortune = nftHero.getFortune(targetTokenId);

    uint256 tmpRandom = 1000000000000;
    uint256 maxRandomValue = 1000000000000;
    uint256 heroRandom = tmpRandom.mod(maxRandomValue, "").mul(heroFortune);
    uint256 targetRandom = tmpRandom.mod(maxRandomValue, "").mul(targetFortune);

    uint256 heroAttack = nftHero.getAttack(tokenId);
    uint256 targetDefense = nftHero.getDefense(targetTokenId);

    paymentAction(tokenId, amount, useHeroBalance);

    if (heroAttack.add(heroRandom.mul(heroAttack)) > targetDefense.add(targetRandom.mul(targetDefense))) {
      // victory
      return true;
    } else {
      return false;
    }
  }

  /**
    * @dev Pauses creation heroes.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function pause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "GamePlayersActions: must have pauser role to pause");

    _pause();
  }

  /**
    * @dev Unpauses creation heroes.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function unpause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "GamePlayersActions: must have pauser role to unpause");

    _unpause();
  }

  /**
    * @dev Set heroes coordinates contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGameHeroCoordinatesAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set address");

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
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set address");

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
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set NFT Hero contract");

    _setNftHeroAddress(nftHeroAddress);
  }

  /**
    * @dev Set game pay address.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGamePayAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set pay contract address");

    _setGamePayAddress(contractAddress);
  }

  /**
    * @dev Set game pay address.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setHeroBalanceAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set hero balance contract address");

    _setHeroBalanceAddress(contractAddress);
  }

  /**
    * @dev Set game hero stamina contract address.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGameHeroStaminaAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePlayersActions: must have admin role to set contract address");

    _setGameHeroStaminaAddress(contractAddress);
  }
}
