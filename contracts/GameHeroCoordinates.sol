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

  mapping(uint256 => mapping(uint256 => uint256)) internal coordinatesToUnits;
  mapping(uint256 => Math2d.Point) internal unitsToCoordinates;

  function getTokenIdByCoordinates(Math2d.Point memory coordinates) public view returns(uint256) {
    return coordinatesToUnits[coordinates.x][coordinates.y];
  }

  function getCoordinatesByTokenId(uint256 tokenId) public view returns(Math2d.Point memory) {
    return unitsToCoordinates[tokenId];
  }

  function getChunk(uint256 x1, uint256 y1) public view returns(uint256[] memory) {
    uint256 x2 = x1 + chunkSize;
    uint256 y2 = y1 + chunkSize;
    uint256 currentX;
    uint256 currentY;
    uint256 countUnits = 0;
    
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

    uint256[] memory herosArr = new uint256[](countUnits);

    for (uint256 index = 0; index < countUnits; index += 1) {
      herosArr[index] = unitsFullArr[index];
    }

    return herosArr;
  }

  function setHeroCoordinates(uint256 tokenId, Math2d.Point memory newCoordinates) external {
    require(hasRole(GAME_ROLE, _msgSender()), "GameNftHeroCoordinatesStore: must have game role to set hero coordinates");

    require(
      newCoordinates.x > 0
      && newCoordinates.y > 0
      && newCoordinates.x < worldSize
      && newCoordinates.y < worldSize
      , "You can't go outside the world"
    );
    require(
      coordinatesToUnits[newCoordinates.x][newCoordinates.x] == 0
      || coordinatesToUnits[newCoordinates.x][newCoordinates.x] == tokenId
      , "There is someone standing there"
    );

    require(world.getCell(newCoordinates.x, newCoordinates.y).mainlandId > 0);

    Math2d.Point memory currentCoordinates = unitsToCoordinates[tokenId];
    coordinatesToUnits[currentCoordinates.x][currentCoordinates.y] = 0;
    coordinatesToUnits[newCoordinates.x][newCoordinates.y] = tokenId;
    unitsToCoordinates[tokenId] = newCoordinates;

    emit UpdateHeroCoordinates(
      tokenId,
      currentCoordinates,
      newCoordinates,
      getChunkCoordinatesByPoint(currentCoordinates),
      getChunkCoordinatesByPoint(newCoordinates)
    );
  }

  function removeTokenId(uint256 tokenId) public {
    require(hasRole(GAME_ROLE, _msgSender()), "GameNftHeroCoordinatesStore: must have game role to remove hero");

    Math2d.Point memory heroCoordinates = unitsToCoordinates[tokenId];
    coordinatesToUnits[heroCoordinates.x][heroCoordinates.y] = 0;
    unitsToCoordinates[tokenId] = Math2d.Point(0, 0);

    emit RemoveHero(
      tokenId,
      getChunkCoordinatesByPoint(heroCoordinates)
    );
  }

  function setChunkSize(uint256 chunkSize) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GameNftHeroCoordinatesStore: must have admin role to set chunk size");

    _setChunkSize(chunkSize);
  }

  function setWorldAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GameNftHeroCoordinatesStore: must have admin role to set world contract address");

    _setWorldAddress(contractAddress);
  }
}

