// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "./utils/Chunkable.sol";
import "./utils/Owner.sol";
import "./Mainland.sol";

contract World is Owner, Chunkable {
  Mainland[] mainlands;

  function getChunk(uint256 x1, uint256 y1) public view returns(Mainland.CellData[] memory) {
    uint256 x2 = x1 + chunkSize;
    uint256 y2 = y1 + chunkSize;
    uint256 index = 0;
    uint256 currentX;
    uint256 currentY;
    
    Mainland.CellData[] memory mainlandsCellArr = new Mainland.CellData[](chunkSize * chunkSize);

    for (currentX = x1; currentX < x2; currentX += 1) {
      for (currentY = y1; currentY < y2; currentY += 1) {
        mainlandsCellArr[index] = getCell(currentX, currentY);
        index += 1;
      }   
    }
    
    return mainlandsCellArr;
  }

  function getCell(uint256 x, uint256 y) public view returns(Mainland.CellData memory celldata) {
    uint32 mainlandsIndex;

    for (mainlandsIndex = 0; mainlandsIndex < mainlands.length; mainlandsIndex += 1) {
      if (
        mainlands[mainlandsIndex].getMainlandsX() <= x
        && mainlands[mainlandsIndex].getMainlandsY() <= y
        && mainlands[mainlandsIndex].getMainlandsX() + mainlands[mainlandsIndex].getMainlandsSize() >= x
        && mainlands[mainlandsIndex].getMainlandsY() + mainlands[mainlandsIndex].getMainlandsSize() >= y
      ) {
        celldata = mainlands[mainlandsIndex].getCell(x, y);
        break;
      }
    }
  }

  function addMainland(address mainlandAddress) public isOwner {
    Mainland newMainland = Mainland(mainlandAddress);

    mainlands.push(newMainland);
  }

  function removeMainland(uint index) public isOwner {
    require(index < mainlands.length);

    Mainland[] memory newMainlands;

    for (uint i = 0; i < mainlands.length; i++){
      if (i != index) {
        newMainlands[i] = mainlands[i];
      }
    }

    mainlands = newMainlands;
  }

  function setChunkSize(uint256 chunkSize) public isOwner {
    _setChunkSize(chunkSize);
  }
}
