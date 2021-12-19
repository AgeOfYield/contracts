// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract AvailableTokens {
  address[100] internal _availableTokens;
  uint8 internal _availableTokensLength;
  uint8 maxAvailableTokens = 100;

  function _addAvailableToken(address tokenAddress) internal virtual {
    require(_availableTokensLength < maxAvailableTokens);

    _availableTokens[_availableTokensLength] = tokenAddress;
    _availableTokensLength += 1;
  }

  function _removeAvailableToken(uint8 index) internal virtual {
    uint8 availableTokensLength = _availableTokensLength;

    require(availableTokensLength !=0 && availableTokensLength > index);

    uint8 newAvailableTokensLength = availableTokensLength - 1;

    _availableTokens[index] = _availableTokens[newAvailableTokensLength];
    _availableTokensLength = newAvailableTokensLength;

    delete _availableTokens[newAvailableTokensLength];
  }

  function getAvailableTokens(uint8 index) public view returns(address) {
    return _availableTokens[index];
  }

  function getAvailableTokensLength() public view returns(uint8) {
    return _availableTokensLength;
  }
}
