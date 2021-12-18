// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AgeOfYieldToken is ERC20("Age Of Yield", "AOY"), AccessControl {
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor() {
    _mint(_msgSender(), (10**18) * 10e9);
    
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(BURNER_ROLE, _msgSender());
    _setupRole(MINTER_ROLE, _msgSender());
  }

  function burn(address fromAddress, uint256 amount) public {
    require(hasRole(BURNER_ROLE, _msgSender()), "AgeOfYieldToken: must have burner role to burne tokens");

    _burn(fromAddress, amount);
  }

  function mint(uint256 amount) public {
    require(hasRole(MINTER_ROLE, _msgSender()), "AgeOfYieldToken: must have minter role to mint tokens");

    _mint(_msgSender(), amount);
  }
}
