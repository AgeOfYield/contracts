// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract HeroScore {
  using SafeMath for uint256;

  /**
    * @dev Emitted when the hero score is changed.
    */
  event ChangeScore(uint256 indexed tokenId, uint256 score);

  uint256 internal scoreFactorA = 1;
  uint256 internal scoreFactorC = 1;

  // Mapping token id to hero name
  mapping(uint256 => uint256) internal _score;

  function getScore(uint256 tokenId) public view virtual returns(uint256) {
    return _score[tokenId];
  }

  function addScore(uint256 tokenId, uint256 value) public virtual {
    (bool isSuccess, uint256 newScore) = _score[tokenId].tryAdd(value);
    require(isSuccess, "");

    _score[tokenId] = newScore;

    emit ChangeScore(tokenId, newScore);
  }

  function subScore(uint256 tokenId, uint256 value) public virtual {
    (bool isSuccess, uint256 newScore) = _score[tokenId].trySub(value);
    require(isSuccess, "");
  
    _score[tokenId] = newScore;

    emit ChangeScore(tokenId, newScore);
  }

  function setScoreFactorA(uint256 factorA) public virtual {
    scoreFactorA = factorA;
  }

  function setScoreFactorC(uint256 factorC) public virtual {
    scoreFactorC = factorC;
  }

  function getScoreByLevel(uint256 level) public view returns(uint256 score) {
    bool success = false;
    uint256 xPow2 = 0;
    uint256 a = 0;

    (success, xPow2) = level.tryMul(level);
    (success, a) = scoreFactorA.tryMul(xPow2);
    (success, score) = a.tryAdd(scoreFactorC);

    require(success, "HeroScore: can not get score");
  }
}
