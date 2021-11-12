// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./utils/Chunkable.sol";
import "./lib/Math2d.sol";
import "./UseWorld.sol";

contract GameHeroCoordinates is AccessControl, Chunkable, UseWorld {
  uint256 public constant worldSize = 2**255 - 1;

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(ADMIN_ROLE, _msgSender());
    _setupRole(GAME_ROLE, _msgSender());
  }

  event UpdateHeroCoordinates(
    uint256 indexed tokenId,
    Math2d.Point from,
    Math2d.Point to,
    Math2d.Point indexed fromChunk,
    Math2d.Point indexed toChunk
  );

  event RemoveHero(
    uint256 indexed tokenId,
    Math2d.Point indexed chunk
  );

  mapping(uint256 => mapping(uint256 => uint256)) internal coordinatesToHero;
  mapping(uint256 => Math2d.Point) internal heroToCoordinates;
  mapping(uint256 => uint32) internal _heroToMainlandId;

  function getTokenIdByCoordinates(Math2d.Point memory coordinates) public view returns(uint256) {
    return coordinatesToHero[coordinates.x][coordinates.y];
  }

  function getCoordinates(uint256 tokenId) public view returns(Math2d.Point memory) {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to get distance");

    return heroToCoordinates[tokenId];
  }

  function calcDistancePow2(uint256 tokenId, Math2d.Point memory point2) public view returns(uint256) {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to get distance");

    Math2d.Point memory point1 = getCoordinates(tokenId);

    return Math2d.distance2dPow2(point1, point2);
  }

  function calcHeroesDistancePow2(uint256 tokenId1, uint256 tokenId2) public view returns(uint256) {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to get distance");

    Math2d.Point memory point1 = getCoordinates(tokenId1);
    Math2d.Point memory point2 = getCoordinates(tokenId2);

    return Math2d.distance2dPow2(point1, point2);
  }

  function calcDistance(uint256 tokenId, Math2d.Point memory point2) public view returns(uint256) {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to get distance");

    Math2d.Point memory point1 = getCoordinates(tokenId);

    return Math2d.distance2d(point1, point2);
  }

  function calcHeroesDistance(uint256 tokenId1, uint256 tokenId2) public view returns(uint256) {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to get distance");

    Math2d.Point memory point1 = getCoordinates(tokenId1);
    Math2d.Point memory point2 = getCoordinates(tokenId2);

    return Math2d.distance2d(point1, point2);
  }

  function getChunk(uint256 x1, uint256 y1) public view returns(uint256[] memory) {
    uint256 x2 = x1 + chunkSize;
    uint256 y2 = y1 + chunkSize;
    uint256 currentX;
    uint256 currentY;
    uint256 countUnits;
    
    uint256[] memory unitsFullArr = new uint256[](chunkSize * chunkSize);

    for (currentX = x1; currentX < x2; currentX += 1) {
      for (currentY = y1; currentY < y2; currentY += 1) {
        uint256 unitsId = getTokenIdByCoordinates(Math2d.Point(currentX, currentY));
        
        if (unitsId != 0) {
          unitsFullArr[countUnits] = unitsId;
          countUnits += 1;
        }
      }
    }

    uint256[] memory heroesArr = new uint256[](countUnits);

    for (uint256 index = 0; index < countUnits; index += 1) {
      heroesArr[index] = unitsFullArr[index];
    }

    return heroesArr;
  }

  function setHeroCoordinates(uint256 tokenId, Math2d.Point memory newCoordinates) external {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to set hero coordinates");

    require(
      newCoordinates.x > 0
      && newCoordinates.y > 0
      && newCoordinates.x < worldSize
      && newCoordinates.y < worldSize
      , "You can't go outside the world"
    );
    require(
      coordinatesToHero[newCoordinates.x][newCoordinates.x] == 0
      || coordinatesToHero[newCoordinates.x][newCoordinates.x] == tokenId
      , "There is someone standing there"
    );

    uint32 currentMainlandId = _heroToMainlandId[tokenId];

    if (currentMainlandId == 0) {
      currentMainlandId = world.getMainlandId(newCoordinates);
      _heroToMainlandId[tokenId] = currentMainlandId;
    }

    require(world.isLand(newCoordinates, currentMainlandId));

    Math2d.Point memory currentCoordinates = heroToCoordinates[tokenId];
    delete coordinatesToHero[currentCoordinates.x][currentCoordinates.y];
    coordinatesToHero[newCoordinates.x][newCoordinates.y] = tokenId;
    heroToCoordinates[tokenId] = newCoordinates;

    emit UpdateHeroCoordinates(
      tokenId,
      currentCoordinates,
      newCoordinates,
      getChunkCoordinatesByPoint(currentCoordinates),
      getChunkCoordinatesByPoint(newCoordinates)
    );
  }

  function removeTokenId(uint256 tokenId) public {
    require(hasRole(GAME_ROLE, _msgSender()), "GameHeroCoordinates: must have game role to remove hero");

    Math2d.Point memory heroCoordinates = heroToCoordinates[tokenId];

    delete coordinatesToHero[heroCoordinates.x][heroCoordinates.y];
    delete heroToCoordinates[tokenId];
    delete _heroToMainlandId[tokenId];

    emit RemoveHero(
      tokenId,
      getChunkCoordinatesByPoint(heroCoordinates)
    );
  }

  function setChunkSize(uint256 chunkSize) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GameHeroCoordinates: must have admin role to set chunk size");

    _setChunkSize(chunkSize);
  }

  function setWorldAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GameHeroCoordinates: must have admin role to set world contract address");

    _setWorldAddress(contractAddress);
  }
}

