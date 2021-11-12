// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./NftHero/UseNftHero.sol";
import "./UseGamePay.sol";
import "./UseGameSpawn.sol";

contract HeroBalance is UseGamePay, UseGameSpawn, UseNftHero, AccessControl, Pausable {
  using SafeMath for uint256;

  address public aoyAddress;
  
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant DEPOSIT_ROLE = keccak256("DEPOSIT_ROLE");
  bytes32 public constant WITHDRAWAL_ROLE = keccak256("WITHDRAWAL_ROLE");
  bytes32 public constant REDUCE_BALANCE_ROLE = keccak256("REDUCE_BALANCE_ROLE");
  bytes32 public constant INCREASE_BALANCE_ROLE = keccak256("INCREASE_BALANCE_ROLE");

  mapping(uint256 => mapping(address => uint256)) private _balances;
  mapping(address => uint256) private _totalBalances;
  mapping(address => uint256) private _capacityMul;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());
    _setupRole(DEPOSIT_ROLE, _msgSender());
    _setupRole(WITHDRAWAL_ROLE, _msgSender());
    _setupRole(REDUCE_BALANCE_ROLE, _msgSender());
    _setupRole(INCREASE_BALANCE_ROLE, _msgSender());

    _pause();
  }

  /**
    * @dev Returns the amount of tokens owned by `tokenId`.
    */
  function balanceOf(address tokenAddress, uint256 tokenId) public view returns (uint256) {
    return _balances[tokenId][tokenAddress];
  }

  function getCapacity(address tokenAddress, uint256 tokenId) public view returns (uint256) {
    uint256 capacity = nftHero.getCapacity(tokenId);

    return _capacityMul[tokenAddress].mul(capacity);
  }

  /**
    * @dev Moves `amount` tokens from the payer's account to hero balance.
    * See {GamePay-pay}.
    *
    * Requirements:
    *
    * - the caller must have the `DEPOSIT_ROLE`.
    */
  function deposit(address tokenAddress, uint256 tokenId, uint256 amount) public {
    require(hasRole(DEPOSIT_ROLE, _msgSender()), "HeroBalance: must have deposit role to deposit");

    address heroOwner = gameSpawn.ownerOf(tokenId);
    uint256 capacity = getCapacity(tokenAddress, tokenId);
    uint256 balance = balanceOf(tokenAddress, tokenId);

    require(capacity >= balance.add(amount), "HeroBalance: limit exceeded");

    gamePay.pay(heroOwner, address(this), tokenAddress, amount);

    _increaseBalance(tokenAddress, tokenId, amount);
  }

  /**
    * @dev Moves `amount` tokens from hero balance to the payer's account.
    * See {GamePay-pay}.
    *
    * Requirements:
    *
    * - the caller must have the `WITHDRAWAL_ROLE`.
    */
  function withdrawal(address tokenAddress, uint256 tokenId, uint256 amount) public {
    require(hasRole(WITHDRAWAL_ROLE, _msgSender()), "HeroBalance: must have withdrawal role to deposit");

    IERC20 tokenContract = IERC20(tokenAddress);
    address heroOwner = gameSpawn.ownerOf(tokenId);

    tokenContract.transfer(heroOwner, amount);
    _reduceBalance(tokenAddress, tokenId, amount);
  }

  /**
    * See {HeroBalance-_reduceBalance}.
    *
    * Requirements:
    *
    * - the caller must have the `REDUCE_BALANCE_ROLE`.
    */
  function reduceAoyBalance(uint256 tokenId, uint256 amount) public {
    require(hasRole(REDUCE_BALANCE_ROLE, _msgSender()), "HeroBalance: must have reduce balance role to reduce balance");

    _reduceBalance(aoyAddress, tokenId, amount);
  }

  /**
    * See {HeroBalance-_reduceBalance}.
    *
    * Requirements:
    *
    * - the caller must have the `REDUCE_BALANCE_ROLE`.
    */
  function reduceBalance(address tokenAddress, uint256 tokenId, uint256 amount) public {
    require(hasRole(REDUCE_BALANCE_ROLE, _msgSender()), "HeroBalance: must have reduce balance role to reduce balance");

    _reduceBalance(tokenAddress, tokenId, amount);
  }

  /**
    * See {HeroBalance-_increaseBalance}.
    *
    * Requirements:
    *
    * - the caller must have the `INCREASE_BALANCE_ROLE`.
    */
  function increaseAoyBalance(uint256 tokenId, uint256 amount) internal {
    require(hasRole(INCREASE_BALANCE_ROLE, _msgSender()), "HeroBalance: must have increase balance role to increase balance");

    _increaseBalance(aoyAddress, tokenId, amount);
  }

  /**
    * See {HeroBalance-_increaseBalance}.
    *
    * Requirements:
    *
    * - the caller must have the `INCREASE_BALANCE_ROLE`.
    */
  function increaseBalance(address tokenAddress, uint256 tokenId, uint256 amount) internal {
    require(hasRole(INCREASE_BALANCE_ROLE, _msgSender()), "HeroBalance: must have increase balance role to increase balance");

    _increaseBalance(tokenAddress, tokenId, amount);
  }

  function _reduceBalance(address tokenAddress, uint256 tokenId, uint256 amount) internal {
    require(balanceOf(tokenAddress, tokenId) >= amount, "HeroBalance: amount exceeds balance");

    _balances[tokenId][tokenAddress] = _balances[tokenId][tokenAddress].sub(amount);
    _totalBalances[tokenAddress] = _totalBalances[tokenAddress].sub(amount);
  }

  function _increaseBalance(address tokenAddress, uint256 tokenId, uint256 amount) internal {
    uint256 capacity = nftHero.getCapacity(tokenId);
    uint256 newBalance = balanceOf(tokenAddress, tokenId);

    require(_capacityMul[tokenAddress].mul(capacity) <= newBalance, "");

    _balances[tokenId][tokenAddress] = _balances[tokenId][tokenAddress].add(newBalance);
    _totalBalances[tokenAddress] += _totalBalances[tokenAddress].add(amount);
  }

  /**
    * @dev Set game pay address.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGamePayAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroBalance: must have admin role to set price");

    _setGamePayAddress(contractAddress);
  }

  /**
    * @dev Set spawn contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGameSpawnAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroBalance: must have admin role to set address");

    _setGameSpawnAddress(contractAddress);
  }

  function setAoyAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroBalance: must have admin role to set AOY token address");
    aoyAddress = contractAddress;
  }

  /**
    * @dev Set NFT Heroes contract.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setNftHeroAddress(address nftHeroAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GameSpawn: must have admin role to set NFT Hero contract");
    _setNftHeroAddress(nftHeroAddress);
  }
}
