// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./NftHero/UseNftHero.sol";
import "./UseGameSpawn.sol";

contract GameHeroStamina is UseNftHero, UseGameSpawn, AccessControl {
  using SafeMath for uint256;

  event Spend(
    uint256 indexed tokenId,
    uint256 block,
    uint256 stamina
  );

  struct Expense {
    uint256 time;
    uint256 value;
  }

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant STAMINA_RESETER_ROLE = keccak256("STAMINA_RESETER_ROLE");
  bytes32 public constant STAMINA_SPENDER_ROLE = keccak256("STAMINA_SPENDER_ROLE");
  bytes32 public constant STAMINA_VIEWER_ROLE = keccak256("STAMINA_VIEWER_ROLE");

  mapping(uint256 => Expense) expense;
  uint256 public restoreFactor = 1000000;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(ADMIN_ROLE, _msgSender());
    _setupRole(STAMINA_RESETER_ROLE, _msgSender());
    _setupRole(STAMINA_SPENDER_ROLE, _msgSender());
    _setupRole(STAMINA_VIEWER_ROLE, _msgSender());
  }

  function calculateTime(uint256 tokenId) internal view returns(uint256) {
    uint256 end = block.number;
    uint256 totalTime = end.sub(expense[tokenId].time);

    return totalTime;
  }

  function calculateRestoredStamina(uint256 tokenId) internal view returns(uint256) {
    uint256 restoredStamina = calculateTime(tokenId).mul(restoreFactor);

    return restoredStamina;
  }

  /**
    * @dev Calc stamina by token id.
    *
    * Requirements:
    *
    * - the caller must have the `STAMINA_VIEWER_ROLE`.
    */
  function getStamina(uint256 tokenId) public view returns(uint256) {
    require(
      (
        hasRole(STAMINA_VIEWER_ROLE, _msgSender())
        || gameSpawn.ownerOf(tokenId) == _msgSender()
      )
      , "HeroStamina: must have stamina viewer role or be owner to get stamina");

    uint256 restoredStamina = calculateRestoredStamina(tokenId);

    if (expense[tokenId].value < restoredStamina) {
      return 0;
    } else {
      uint256 stamina = expense[tokenId].value.sub(restoredStamina);
      uint256 heroMaxStamina = nftHero.getStamina(tokenId);

      if (stamina > heroMaxStamina) {
        return heroMaxStamina;
      } else {
        return stamina;
      }
    }
  }

  /**
    * @dev Spand stamina by token id.
    *
    * Requirements:
    *
    * - the caller must have the `STAMINA_RESETER_ROLE`.
    */
  function spendStamina(uint256 tokenId, uint256 value) public {
    require(hasRole(STAMINA_SPENDER_ROLE, _msgSender()), "HeroStamina: must have stamina spander role to spand stamina");

    uint256 stamina = getStamina(tokenId);

    require(stamina >= value, "HeroStamina: can not spend stamina");

    uint256 restoredStamina = calculateRestoredStamina(tokenId);

    if (expense[tokenId].value <= restoredStamina) {
      expense[tokenId].value = value;
      expense[tokenId].time = block.number;
    } else {
      bool success = false;

      (success, expense[tokenId].value) = expense[tokenId].value.tryAdd(value);

      if (!success) {
        revert("HeroStamina: can not spend stamina");
      }
    }

    emit Spend(tokenId, block.number, getStamina(tokenId));
  }

  /**
    * @dev Reset stamina by token id.
    *
    * Requirements:
    *
    * - the caller must have the `STAMINA_RESETER_ROLE`.
    */
  function resetStamina(uint256 tokenId) public {
    require(hasRole(STAMINA_RESETER_ROLE, _msgSender()), "HeroStamina: must have stamina reseter role to reset stamina");

    expense[tokenId] = Expense(0, 0);
  }

  /**
    * @dev Set stamina restore factor.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setRestoreFactor(uint256 factor) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroStamina: must have admin role to set restore factor");

    restoreFactor = factor;
  }

  /**
    * @dev Set NFT Heroes contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setNftHeroAddress(address nftHeroAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroStamina: must have admin role to set NFT Hero contract");
    _setNftHeroAddress(nftHeroAddress);
  }
}
