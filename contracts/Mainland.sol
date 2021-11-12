// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "./lib/Math2d.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Mainland {
  uint256 internal _mainlandsSize;
  Math2d.Point internal _mainlandsCoordinates;
  Math2d.Point internal _mainlandsCenter;
  uint256 internal _mainlandsRadius;
  uint256 internal _mainlandsRadiusPow2;
  uint32 internal _mainlandsId;

  using SafeMath for uint256;

  struct CellData {
    uint32 mainlandId;

    uint256 poolSize;
  }

  constructor(
    uint32 mainlandsId,
    uint256 mainlandsX,
    uint256 mainlandsY,
    uint256 mainlandsSize
  ) {
    _mainlandsCoordinates = Math2d.Point(mainlandsX, mainlandsY);
    _mainlandsSize = mainlandsSize;

    uint256 mainlandsRadius = mainlandsSize / 2;

    _mainlandsCenter = Math2d.Point(mainlandsX + mainlandsRadius, mainlandsY + mainlandsRadius);
    _mainlandsRadiusPow2 = mainlandsRadius ** 2;
    _mainlandsId = mainlandsId;
    _mainlandsRadius = mainlandsRadius;
  }

  function getId() public view returns(uint32) {
    return _mainlandsId;
  }

  function getMainlandsX() public view returns(uint256) {
    return _mainlandsCoordinates.x;
  }

  function getMainlandsY() public view returns(uint256) {
    return _mainlandsCoordinates.y;
  }

  function getMainlandsSize() public view returns(uint256) {
    return _mainlandsSize;
  }

  function getFarm(Math2d.Point memory point) public pure returns(uint256) {
    uint8 randomValue = uint8(uint256(keccak256(abi.encodePacked(point.x, point.y))) % 251);

    if (randomValue % 9 != 0) {
      return 0;
    }

    return 10000;
  }

  function isLand(Math2d.Point memory point) public view returns(bool) {
    Math2d.Point memory mainlandsCoordinates = _mainlandsCoordinates;
    uint256 mainlandsSize = _mainlandsSize;

    return (
      point.x < mainlandsCoordinates.x
      || point.y < mainlandsCoordinates.y
      || point.x > mainlandsCoordinates.x + mainlandsSize
      || point.y > mainlandsCoordinates.y + mainlandsSize
    );
  }

  function getCell(Math2d.Point memory point) public view returns(CellData memory) {
    if (isLand(point) == false) {
      return CellData(0, 0);
    }

    Math2d.Point memory mainlandsCenter = _mainlandsCenter;
    uint256 dx;
    uint256 dy;

    if (point.x < mainlandsCenter.x) {
      dx = mainlandsCenter.x.sub(point.x, "dx out diapason");
    } else {
      dx = point.x.sub(mainlandsCenter.x, "dx out diapason");
    }

    if (point.y < mainlandsCenter.y) {
      dy = mainlandsCenter.y.sub(point.y, "dy out diapason");
    } else {
      dy = point.y.sub(mainlandsCenter.y, "dy out diapason");
    }

    uint256 localX = dx.mul(dx);
    uint256 localY = dy.mul(dy);

    if (localX + localY >= _mainlandsRadiusPow2) {
      return CellData(0, 0);
    }

    return CellData(_mainlandsId, getFarm(point));
  }
}