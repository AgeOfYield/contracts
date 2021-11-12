// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract GamePay is AccessControl, Pausable {
  address public aoyAddress;

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant WITHDRAWAL_ROLE = keccak256("WITHDRAWAL_ROLE");
  bytes32 public constant PAYMENT_ROLE = keccak256("PAYMENT_ROLE");

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());
    _setupRole(WITHDRAWAL_ROLE, _msgSender());
    _setupRole(PAYMENT_ROLE, _msgSender());

    _pause();
  }

  /**
    * @dev Moves `amount` tokens from `payer` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Requirements:
    *
    * - `payer`, `recipient` and `token` cannot be the zero address.
    * - `payer` must have a balance of at least `amount`.
    * - the payer must have allowance for ``sender``'s tokens of at least
    * `amount`.
    */
  function _pay(address payer, address recipient, address token, uint256 amount) private returns(bool) {
    require(!paused(), "GamePay: Paused");
    require(
      (
        address(0) != payer
        && address(0) != recipient
        && address(0) != token
        && amount != 0
      )
    );

    IERC20 paymentToken = IERC20(token);
    uint256 allowance = paymentToken.allowance(payer, recipient);

    require(allowance >= amount, "GamePay: Amount exceeds allowance");

    return paymentToken.transferFrom(payer, recipient, amount);
  }

  /**
    * @dev Transfer tokens.
    * See {GamePay-_pay}.
    *
    * Requirements:
    *
    * - the caller must have the `PAYMENT_ROLE`.
    */
  function pay(address payer, address recipient, address token, uint256 amount) public {
    require(hasRole(PAYMENT_ROLE, _msgSender()), "GamePay: must have payment role");

    bool success = _pay(payer, recipient, token, amount);

    require(success, "GamePay: can not transfer tokens");
  }

  /**
    * @dev Transfer tokens from payer to contract address.
    * See {GamePay-_pay}.
    *
    * Requirements:
    *
    * - the caller must have the `PAYMENT_ROLE`.
    */
  function payAoy(address payer, uint256 amount) public {
    require(hasRole(PAYMENT_ROLE, _msgSender()), "GamePay: must have payment role");

    bool success = _pay(payer, address(this), aoyAddress, amount);

    require(success, "GamePay: can not transfer tokens");
  }

  /**
    * @dev Withdrawal of accumulated tokens.
    *
    * Requirements:
    *
    * - the caller must have the `WITHDRAWAL_ROLE`.
    */
  function withdrawalAccamulatedTokens(address recipient, address token) public {
    require(!paused(), "GamePay: Paused");
    require(hasRole(WITHDRAWAL_ROLE, _msgSender()), "GamePay: must have withdrawal role to withdrawal");

    IERC20 paymentToken = IERC20(token);

    uint256 balance = paymentToken.balanceOf(address(this));
    paymentToken.transfer(recipient, balance);
  }

  function setAoyAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GamePay: must have admin role to set AOY token address");
    aoyAddress = contractAddress;
  }
}
