// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./UseGameHeroCoordinates.sol";
import "./UseUnitsStore.sol";
import "./NftHero/UseNftHero.sol";
import "./utils/Owner.sol";

contract GamePlayersHeros is
  Pausable,
  AccessControl,
  UseGameHeroCoordinates,
  UseUnitsStore,
  UseNftHero
{
  struct PlayersHero {
    uint256 level;
    uint256 score;
    Math2d.Point coordinates;
    uint256 attack;
    uint256 maxPower;
    uint256 maxWayLength;
    uint256 farmingRate;
    uint256 powerRecoveryRate;
  }

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  /**
    * @dev Grants `DEFAULT_ADMIN_ROLE`, `PAUSER_ROLE`, `ADMIN_ROLE` to the account that
    * deploys the contract.
    */
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());

    _pause();
  }

  /**
    * @dev Pauses creation heros.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function pause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "Player: must have pauser role to pause");
    _pause();
  }

  /**
    * @dev Unpauses creation heros.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function unpause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "Player: must have pauser role to unpause");
    _unpause();
  }

  function getHero(uint256 tokenId) public view returns(PlayersHero memory) {
    require(nftHero.ownerOf(tokenId) == _msgSender());

    PlayersHero memory playersUnit = PlayersHero({
      level: nftHero.getLevel(tokenId),
      score: nftHero.getScore(tokenId),
      coordinates: gameHeroCoordinates.getCoordinatesByTokenId(tokenId),
      attack: unitsStore.getUnitsAttack(tokenId),
      maxPower: unitsStore.getUnitsMaxPower(tokenId),
      maxWayLength: unitsStore.getUnitsMaxWayLength(tokenId),
      farmingRate: unitsStore.getUnitsFarmingRate(tokenId),
      powerRecoveryRate: unitsStore.getUnitsPowerRecoveryRate(tokenId)
    });
    
    return playersUnit;
  }

  function move(uint256 tokenId, Math2d.Point memory point) public {
    require(!paused(), "Player: paused");
    require(nftHero.ownerOf(tokenId) == _msgSender());

    uint256 multipleDecimal = 100;
    uint256 maxDistance = unitsStore.getUnitsMaxWayLength(tokenId);
    Math2d.Point memory coordinates = gameHeroCoordinates.getCoordinatesByTokenId(tokenId);

    uint256 dx = Math2d.distance(coordinates.x, point.x);
    uint256 dy = Math2d.distance(coordinates.y, point.y);

    require(dx <= maxDistance, "too far distance");
    require(dy <= maxDistance, "too far distance");
    require((dx * multipleDecimal) ** 2 + (dy * multipleDecimal) ** 2 <= maxDistance ** 2, "too far distance");

    gameHeroCoordinates.setHeroCoordinates(tokenId, point);
  }

  function setGameHeroCoordinatesStoreAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "Player: must have admin role to set address");

    _setGameHeroCoordinatesAddress(contractAddress);
  }

  function setUnitsStoreAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "Player: must have admin role to set address");

    _setUnitsStoreAddress(contractAddress);
  }

    /**
    * @dev Set NFT Heros contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setNftHeroAddress(address nftHeroAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "Player: must have admin role to set NFT Hero contract");
    _setNftHeroAddress(nftHeroAddress);
  }
}