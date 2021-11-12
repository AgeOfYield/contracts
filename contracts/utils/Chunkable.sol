// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/Math2d.sol";

contract Chunkable {
  uint256 internal chunkSize = 10;
  
  function getChunkSize() public view returns(uint256) {
    return chunkSize;
  }
  
  function _setChunkSize(uint256 newChunkSize) internal {
    chunkSize = newChunkSize;
  }

  function getChunkCoordinatesByPoint(Math2d.Point memory point) public view returns (Math2d.Point memory chunkCoordinates) {

  }
}
