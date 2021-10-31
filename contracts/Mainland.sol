// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "./lib/Math2d.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Mainland {
  uint256 public mainlandsSize;
  Math2d.Point public mainlandsCoordinates;
  Math2d.Point public mainlandsCenter;
  uint256 public mainlandsRadius;
  uint256 public mainlandsRadiusPow2;
  uint256 public mainlandsId;
  Math2d.Vector public mainlandsTopVector;

  using SafeMath for uint256;

  struct CellData {
    uint256 mainlandId;
    uint256 poolSize;
  }

  constructor(uint256 _mainlandsId, uint256 _mainlandsX, uint256 _mainlandsY, uint256 _mainlandsSize) {
    mainlandsCoordinates = Math2d.Point(_mainlandsX, _mainlandsY);
    mainlandsSize = _mainlandsSize;
    mainlandsRadius = _mainlandsSize / 2;
    mainlandsCenter = Math2d.Point(_mainlandsX + mainlandsRadius, _mainlandsY + mainlandsRadius);
    mainlandsRadiusPow2 = mainlandsRadius ** 2;
    mainlandsId = _mainlandsId;
    mainlandsTopVector = Math2d.vector(mainlandsCenter, Math2d.Point(mainlandsRadius, _mainlandsY));
  }

  function getMainlandsX() public view returns(uint256) {
    return mainlandsCoordinates.x;
  }

  function getMainlandsY() public view returns(uint256) {
    return mainlandsCoordinates.y;
  }

  function getMainlandsSize() public view returns(uint256) {
    return mainlandsSize;
  }

  function getFarm(uint256 x, uint256 y) public pure returns(uint256) {
    uint8 randomValue = uint8(uint256(keccak256(abi.encodePacked(x, y))) % 251);

    if (randomValue % 9 != 0) {
      return 0;
    }

    return 10000;
  }

  function getCell(uint256 x, uint256 y) public view returns(CellData memory) {
    if (
      x < mainlandsCoordinates.x
      || y < mainlandsCoordinates.y
      || x > mainlandsCoordinates.x + mainlandsSize
      || y > mainlandsCoordinates.y + mainlandsSize
    ) {
      return CellData(0, 0);
    }


    uint256 dx;
    uint256 dy;

    if (x < mainlandsCenter.x) {
      dx = mainlandsCenter.x.sub(x, "dx out diapason");
    } else {
      dx = x.sub(mainlandsCenter.x, "dx out diapason");
    }

    if (y < mainlandsCenter.y) {
      dy = mainlandsCenter.y.sub(y, "dy out diapason");
    } else {
      dy = y.sub(mainlandsCenter.y, "dy out diapason");
    }

    (bool okLocalX, uint256 localX) = dx.tryMul(dx);

    require(okLocalX, "localX out diapason");

    (bool okLocalY, uint256 localY) = dy.tryMul(dy);

    require(okLocalY, "localY out diapason");

    if (localX + localY >= mainlandsRadiusPow2) {
      return CellData(0, 0);
    }

    return CellData(mainlandsId, getFarm(x, y));
  }
}