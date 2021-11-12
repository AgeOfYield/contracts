// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./HeroScore.sol";

abstract contract HeroCharacteristics is HeroScore {
  using SafeMath for uint256;

  uint256 public constant divisorOfCharacteristics = 1000000;
  uint256 public multiplierOfCharacteristics = 1100000;

  /**
    * @dev Emitted when the maxSkillPoints is changed.
    */
  event SkillPoints(uint16 maxSkillPoints);

  /**
    * @dev Emitted when the hero level is apped.
    */
  event LevelUp(uint256 indexed tokenId, uint256 level);

  struct Characteristics {
    uint256 attack;
    uint256 defense;
    uint256 mining;
    uint256 capacity;
    uint256 stamina;
    uint256 fortune;
  }

  uint16 public _skillPoints = 2;

  // Mapping token id to hero level
  mapping(uint256 => uint256) internal _level;

  // Mapping token id to hero characteristics
  mapping(uint256 => Characteristics) internal _characteristics;

  function getLevel(uint256 tokenId) public view returns(uint256) {
    return _level[tokenId];
  }

  function getAttack(uint256 tokenId) public view virtual returns(uint256) {
    return _characteristics[tokenId].attack;
  }

  function getDefense(uint256 tokenId) public view virtual returns(uint256) {
    return _characteristics[tokenId].defense;
  }

  function getMining(uint256 tokenId) public view virtual returns(uint256) {
    return _characteristics[tokenId].mining;
  }

  function getCapacity(uint256 tokenId) public view virtual returns(uint256) {
    return _characteristics[tokenId].capacity;
  }

  function getStamina(uint256 tokenId) public view virtual returns(uint256) {
    return _characteristics[tokenId].stamina;
  }

  function getFortune(uint256 tokenId) public view virtual returns(uint256) {
    return _characteristics[tokenId].fortune;
  }

  function getCharacteristics(uint256 tokenId) public view virtual returns(Characteristics memory) {
    return _characteristics[tokenId];
  }

  function getNextCharacteristicsValue(uint256 value) private view returns(uint256) {
    (bool success, uint256 newValue) = value
      .tryMul(multiplierOfCharacteristics);

    assert(success);

    return newValue.div(divisorOfCharacteristics, "HeroCharacteristics: can not calc value");
  }

  /**
    *
    */
  function levelUp(uint256 tokenId, uint16[] memory characteristics) public virtual {
    require(characteristics.length == _skillPoints, "HeroCharacteristics: incorect characteristics");

    uint256 nextLevel = _level[tokenId] + 1;
    uint256 scoreByNextLevel = getScoreByLevel(nextLevel);

    require(scoreByNextLevel <= getScore(tokenId), "HeroCharacteristics: insufficient scores");
  
    bool upAttack = false;
    bool upDefense = false;
    bool upMining = false;
    bool upCapacity = false;
    bool upStamina = false;
    bool upFortune = false;
    
    for (uint16 index = 0; index < _skillPoints; index++) {
      if (characteristics[index] == 1 && !upAttack) {
        _characteristics[tokenId].attack = getNextCharacteristicsValue(_characteristics[tokenId].attack);
        upAttack = true;
      } else if (characteristics[index] == 2 && !upDefense) {
        _characteristics[tokenId].defense = getNextCharacteristicsValue(_characteristics[tokenId].defense);
        upDefense = true;
      } else if (characteristics[index] == 3 && !upMining) {
        _characteristics[tokenId].mining = getNextCharacteristicsValue(_characteristics[tokenId].mining);
        upMining = true;
      } else if (characteristics[index] == 4 && !upCapacity) {
        _characteristics[tokenId].capacity = getNextCharacteristicsValue(_characteristics[tokenId].capacity);
        upCapacity = true;
      } else if (characteristics[index] == 5 && !upStamina) {
        _characteristics[tokenId].stamina = getNextCharacteristicsValue(_characteristics[tokenId].stamina);
        upStamina = true;
      } else if (characteristics[index] == 6 && !upFortune) {
        _characteristics[tokenId].fortune = getNextCharacteristicsValue(_characteristics[tokenId].fortune);
        upFortune = true;
      } else {
        revert("HeroCharacteristics: incorect characteristics");
      }
    }

    subScore(tokenId, scoreByNextLevel);

    _level[tokenId] = nextLevel;

    emit LevelUp(tokenId, _level[tokenId]);
  }

  function setSkillPoints(uint16 maxSkillPoints) public virtual {
    _skillPoints = maxSkillPoints;
    
    emit SkillPoints(maxSkillPoints);
  }

  function setMultiplierOfCharacteristics(uint256 multiplier) public virtual {
    multiplierOfCharacteristics = multiplier;
  }
}
