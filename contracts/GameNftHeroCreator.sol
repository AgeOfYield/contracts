// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./NftHero/UseNftHero.sol";
import "./NftHero/abstract/HeroCharacteristics.sol";
import "./UseGamePay.sol";

contract GameNftHeroCreator is UseNftHero, UseGamePay, AccessControl, Pausable {
  using SafeMath for uint256;

  struct InitialCharacteristics {
    uint256 attack;
    uint256 defense;
    uint256 mining;
    uint256 capacity;
    uint256 stamina;
    uint256 fortune;
    bool exists;
  }

  struct FactionMulCharacteristics {
    uint256 attack;
    uint256 defense;
    uint256 mining;
    uint256 capacity;
    uint256 stamina;
    uint256 fortune;
    bool exists;
  }

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  uint256 public price = 10 * 10 ** 18;

  InitialCharacteristics[10] public _initialCharacteristics;
  FactionMulCharacteristics[4] public _factionMulCharacteristics;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());

    _pause();
  }

  function getHeroCharacteristicValue(uint256 raceValue, uint256 factionValue, uint256 divisor) private pure returns(uint256) {
    return raceValue.mul(factionValue).div(divisor, "GameNftHeroCreator: incorect divisor");
  }

  function createHero(uint256 race, uint256 gender, uint256 faction, string memory name) public {
    require(!paused(), "HeroCreator: Hero creation paused");
    require(price > 0, "HeroCreator: Price not setted");
    require(!Address.isContract(_msgSender()), "HeroCreator: sender is contract");
    InitialCharacteristics memory initialCharacteristicsOfRace = _initialCharacteristics[race];
    FactionMulCharacteristics memory factionMulCharacteristics = _factionMulCharacteristics[faction];
    require(initialCharacteristicsOfRace.exists, "HeroCreator: initialCharacteristics not setted");
    require(factionMulCharacteristics.exists, "HeroCreator: factionMulCharacteristics not setted");

    gamePay.payAoy(_msgSender(), price);

    uint256 divisorOfCharacteristics = nftHero.divisorOfCharacteristics();
    HeroCharacteristics.Characteristics memory characteristics = HeroCharacteristics.Characteristics(
      // Attack
      getHeroCharacteristicValue(
        initialCharacteristicsOfRace.attack,
        factionMulCharacteristics.attack,
        divisorOfCharacteristics
      ),
      // Defense
      getHeroCharacteristicValue(
        initialCharacteristicsOfRace.defense,
        factionMulCharacteristics.defense,
        divisorOfCharacteristics
      ),
      // Mining
      getHeroCharacteristicValue(
        initialCharacteristicsOfRace.mining,
        factionMulCharacteristics.mining,
        divisorOfCharacteristics
      ),
      // Capacity
      getHeroCharacteristicValue(
        initialCharacteristicsOfRace.capacity,
        factionMulCharacteristics.capacity,
        divisorOfCharacteristics
      ),
      // Stamina
      getHeroCharacteristicValue(
        initialCharacteristicsOfRace.stamina,
        factionMulCharacteristics.stamina,
        divisorOfCharacteristics
      ),
      // Fortune
      getHeroCharacteristicValue(
        initialCharacteristicsOfRace.fortune,
        factionMulCharacteristics.fortune,
        divisorOfCharacteristics
      )
    );

    nftHero.createHero(
      _msgSender(),
      1,
      0,
      race,
      gender,
      faction,
      name,
      characteristics
    );
  }

  /** 
    * @dev Return initial characteristics for hero.
    */
  function getInitialCharacteristics() public view returns(InitialCharacteristics[10] memory) {
    return _initialCharacteristics;
  }


  /**
    * @dev Set inital characteristics for new hero.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setInitialCharacteristics(uint256 index, InitialCharacteristics calldata characteristics) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroCreator: must have admin role to set characteristics");

    _initialCharacteristics[index] = characteristics;
  }

  /** 
    * @dev
    */
  function getFactionMulCharacteristics() public view returns(FactionMulCharacteristics[4] memory) {
    return _factionMulCharacteristics;
  }


  /**
    * @dev
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setFactionMulCharacteristics(uint256 index, FactionMulCharacteristics memory mulCharacteristics) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroCreator: must have admin role to set factionMulCharacteristics");

    _factionMulCharacteristics[index] = mulCharacteristics;
  }

  /**
    * @dev Pauses creation heroes.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function pause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "HeroCreator: must have pauser role to pause");

    _pause();
  }

  /**
    * @dev Unpauses creation heroes.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function unpause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "HeroCreator: must have pauser role to unpause");

    _unpause();
  }

  /**
    * @dev Set price.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setPrice(uint256 newPrice) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroCreator: must have admin role to set price");

    price = newPrice;
  }

  /**
    * @dev Set NFT Heroes contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setNftHeroAddress(address nftHeroAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroCreator: must have admin role to set NFT Hero contract");

    _setNftHeroAddress(nftHeroAddress);
  }
  
  /**
    * @dev Set game pay address.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGamePayAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroCreator: must have admin role to set price");

    _setGamePayAddress(contractAddress);
  }
}
