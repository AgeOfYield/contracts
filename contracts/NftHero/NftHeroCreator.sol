// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UseNftHero.sol";

contract NftHeroCreator is UseNftHero, AccessControl, Pausable {
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant WITHDRAWAL_ROLE = keccak256("WITHDRAWAL_ROLE");

  uint256 public price = 10 * 10 ** 18;
  address public paymentTokenAddress = address(0);

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());
    _setupRole(WITHDRAWAL_ROLE, _msgSender());

    _pause();
  }

  function createHero(uint256 race, uint256 gender, uint256 faction, string memory name) public {
    require(!paused(), "HeroCreator: Hero creation paused");
    require(paymentTokenAddress != address(0), "HeroCreator: Payment token not setted");
    require(price > 0, "HeroCreator: Price not setted");
    require(!Address.isContract(_msgSender()), "HeroCreator: sender is contract");

    IERC20 paymentToken = IERC20(paymentTokenAddress);
    uint256 allowance = paymentToken.allowance(_msgSender(), address(this));

    require(allowance >= price, "HeroCreator: Price amount exceeds allowance");

    paymentToken.transferFrom(_msgSender(), address(this), price);

    nftHero.createHero(
      _msgSender(),
      1,
      0,
      race,
      gender,
      faction,
      name
    );
  }

  /**
    * @dev Withdrawal of accumulated tokens.
    *
    * Requirements:
    *
    * - the caller must have the `WITHDRAWAL_ROLE`.
    */
  function withdrawal(address recipient) public {
    require(hasRole(WITHDRAWAL_ROLE, _msgSender()), "HeroCreator: must have withdrawal role to withdrawal");

    IERC20 paymentToken = IERC20(paymentTokenAddress);

    uint256 balance = paymentToken.balanceOf(address(this));
    paymentToken.transfer(recipient, balance);
  }

  /**
    * @dev Pauses creation heros.
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
    * @dev Unpauses creation heros.
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
    * @dev Set NFT Heros contract.
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
    * @dev Set payment token.
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setPaymentToken(address newPaymentTokenAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "HeroCreator: must have admin role to set price");
    paymentTokenAddress = newPaymentTokenAddress;
  }
}
