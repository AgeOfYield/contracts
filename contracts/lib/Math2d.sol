// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library Math2d {
  using SafeMath for uint256;

  struct Point {
    uint256 x;
    uint256 y;
  }

  function distance1d(uint256 a, uint256 b) internal pure returns(uint256) {
    if (a > b) {
      return a - b;
    } else {
      return b - a;
    }
  }

  function distance2dPow2(Point memory point1, Point memory point2) internal pure returns(uint256 distancePow2) {
    uint256 dx = distance1d(point1.x, point2.x); 
    uint256 dy = distance1d(point1.y, point2.y);
    uint256 dxPow2 = dx.mul(dx);
    uint256 dyPow2 = dy.mul(dy);

    distancePow2 = dxPow2.add(dyPow2);
  }

  function distance2d(Point memory point1, Point memory point2) internal pure returns(uint256) {
    return sqrt(distance2dPow2(point1, point2));
  }

  /**
    * @notice Calculates the square root of x, rounding down.
    * @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    *
    * Caveats:
    * - This function does not work with fixed-point numbers.
    *
    * @param x The uint256 number for which to calculate the square root.
    * @return result The result as an uint256.
    */  
  function sqrt(uint256 x) internal pure returns (uint256 result) {
    if (x == 0) {
      return 0;
    }

    // Set the initial guess to the closest power of two that is higher than x.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 0x100000000000000000000000000000000) {
      xAux >>= 128;
      result <<= 64;
    }
    if (xAux >= 0x10000000000000000) {
      xAux >>= 64;
      result <<= 32;
    }
    if (xAux >= 0x100000000) {
      xAux >>= 32;
      result <<= 16;
    }
    if (xAux >= 0x10000) {
      xAux >>= 16;
      result <<= 8;
    }
    if (xAux >= 0x100) {
      xAux >>= 8;
      result <<= 4;
    }
    if (xAux >= 0x10) {
      xAux >>= 4;
      result <<= 2;
    }
    if (xAux >= 0x8) {
      result <<= 1;
    }

    // The operations can never overflow because the result is max 2^127 when it enters this block.
    unchecked {
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1; // Seven iterations should be enough
      uint256 roundedDownResult = x / result;
      return result >= roundedDownResult ? roundedDownResult : result;
    }
  }
} 