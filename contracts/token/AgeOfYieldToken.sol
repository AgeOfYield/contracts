// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgeOfYieldToken is ERC20("Age Of Yield", "AOY"), Ownable {
  constructor() {
    _mint(_msgSender(), 10**18 * 10 * 9);
  }

  function burn(address fromAddress, uint256 amount) public onlyOwner {
    _burn(fromAddress, amount);
  }

  function mint(uint256 amount) public onlyOwner {
    _mint(_msgSender(), amount);
  }
}
