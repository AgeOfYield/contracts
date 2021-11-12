// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/Chunkable.sol";
import "./Mainland.sol";


contract World is Ownable, Chunkable {
  Mainland[] mainlands;
  mapping(uint32 => Mainland) idToMainland;

  function getChunk(uint256 x1, uint256 y1, uint32 mainlandId) public view returns(Mainland.CellData[] memory) {
    uint256 x2 = x1 + chunkSize;
    uint256 y2 = y1 + chunkSize;
    uint256 index = 0;
    Math2d.Point memory point;
    
    Mainland.CellData[] memory mainlandsCellArr = new Mainland.CellData[](chunkSize * chunkSize);

    for (point.x = x1; point.x < x2; point.x += 1) {
      for (point.y = y1; point.y < y2; point.y += 1) {
        mainlandsCellArr[index] = getCell(point, mainlandId);
        index += 1;
      }   
    }
    
    return mainlandsCellArr;
  }

  function isInsideMainlandById(Math2d.Point memory point, uint32 mainlandId) public view returns(bool) {
    Mainland mainland = idToMainland[mainlandId];

    return isInsideMainland(point, mainland);
  }


  function isInsideMainland(Math2d.Point memory point, Mainland mainland) public view returns(bool) {
    uint256 mainlandsX = mainland.getMainlandsX();
    uint256 mainlandsY = mainland.getMainlandsY();
    uint256 mainlandsSize = mainland.getMainlandsSize();

    return (
      mainlandsX <= point.x
      && mainlandsY <= point.y
      && mainlandsX + mainlandsSize >= point.x
      && mainlandsY + mainlandsSize >= point.y
    );
  }

  function getMainlandId(Math2d.Point memory point) public view returns(uint32 id) {
    uint32 mainlandsIndex;

    for (mainlandsIndex = 0; mainlandsIndex < mainlands.length; mainlandsIndex += 1) {
      if (isInsideMainland(point, mainlands[mainlandsIndex])) {
        id = mainlands[mainlandsIndex].getId();
        break;
      }
    }
  }

  function isLand(Math2d.Point memory point, uint32 mainlandId) public view returns(bool) {
    return idToMainland[mainlandId].isLand(point);
  }

  function getCell(Math2d.Point memory point, uint32 mainlandId) public view returns(Mainland.CellData memory celldata) {
    uint32 mainlandsIndex;

    if (mainlandId != 0) {
      celldata = idToMainland[mainlandId].getCell(point);
    } else {
      for (mainlandsIndex = 0; mainlandsIndex < mainlands.length; mainlandsIndex += 1) {
        if (isInsideMainland(point, mainlands[mainlandsIndex])) {
          celldata = mainlands[mainlandsIndex].getCell(point);
          break;
        }
      }
    }
  }

  function addMainland(address mainlandAddress) public onlyOwner {
    Mainland newMainland = Mainland(mainlandAddress);

    idToMainland[newMainland.getId()] = newMainland;
    mainlands.push(newMainland);
  }

  function removeMainland(uint32 index) public onlyOwner {
    require(index < mainlands.length);

    Mainland currentMainland = mainlands[index];

    Mainland[] memory newMainlands;

    for (uint32 i = 0; i < mainlands.length; i++){
      if (i != index) {
        newMainlands[i] = mainlands[i];
      }
    }

    mainlands = newMainlands;

    delete idToMainland[currentMainland.getId()];
  }

  function setChunkSize(uint256 chunkSize) public onlyOwner {
    _setChunkSize(chunkSize);
  }
}
