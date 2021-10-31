// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../utils/Owner.sol";

contract AgeOfYieldToken is ERC20("Age Of Yield", "AOY"), Owner {
  constructor() {
    _mint(msg.sender, 10**18 * 10* 9);
  }

  function burn(address fromAddress, uint256 amount) public isOwner {
    _burn(fromAddress, amount);
  }
}
