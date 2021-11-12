// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./NftHero/UseNftHero.sol";
import "./UseGameHeroCoordinates.sol";
import "./lib/Math2d.sol";

contract GameSpawn is Pausable, AccessControl, UseNftHero, UseGameHeroCoordinates {
  event DepositHero(uint256 indexed tokenId);
  event WithdrawalHero(uint256 indexed tokenId);

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  // Mapping owner address to token count
  mapping(address => uint256) private _balances;

  // Mapping from token ID to owner address
  mapping(uint256 => address) internal _owners;
  
  // Mapping from owner to list of owned token IDs
  mapping(address => mapping(uint256 => uint256)) internal _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal _ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] private _allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) private _allTokensIndex;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(PAUSER_ROLE, _msgSender());
    _setupRole(ADMIN_ROLE, _msgSender());

    _pause();
  }

  /**
    * @dev Returns the total amount of tokens stored by the contract.
    */
  function totalBalance() public view returns (uint256) {
    return _allTokens.length;
  }

  function ownerOf(uint256 tokenId) public view returns(address) {
    address owner = _owners[tokenId];

    require(owner != address(0), "GameSpawn: owner query for nonexistent token");
    return owner;
  }

  function balanceOf(address owner) public view returns(uint256) {
    require(owner != address(0), "GameSpawn: balance query for the zero address");

    return _balances[owner];
  }

  /**
    * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
    * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
    */
  function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
    require(index < balanceOf(owner), "GameSpawn: owner index out of bounds");
    
    return _ownedTokens[owner][index];
  }

  /**
    * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
    * Use along with {totalBalance} to enumerate all tokens.
    */
  function tokenByIndex(uint256 index) public view returns (uint256) {
    require(index < totalBalance(), "GameSpawn: global index out of bounds");
    return _allTokens[index];
  }


  function depositHero(uint256 tokenId, Math2d.Point memory point) public {
    require(!paused(), "GameSpawn: Heroes' deposit paused");

    require(_owners[tokenId] == address(0));
    require(nftHero.isApprovedForAll(_msgSender(), address(this)), "GameSpawn: Hero not approved");

    nftHero.transferFrom(_msgSender(), address(this), tokenId);

    _owners[tokenId] = _msgSender();

    gameHeroCoordinates.setHeroCoordinates(tokenId, point);

    _addTokenToOwnerEnumeration(_msgSender(), tokenId);
    _addTokenToAllTokensEnumeration(tokenId);
    
    _balances[_msgSender()] += 1;

    emit DepositHero(tokenId);
  }

  function withdrawalHero(uint256 tokenId) public {
    require(!paused(), "GameSpawn: Heroes' withdrawal paused");

    require(_owners[tokenId] == _msgSender());

    nftHero.transfer(_msgSender(), tokenId);

    _owners[tokenId] = address(0);

    gameHeroCoordinates.removeTokenId(tokenId);

    _removeTokenFromOwnerEnumeration(_msgSender(), tokenId);
    _removeTokenFromAllTokensEnumeration(tokenId);
    
    _balances[_msgSender()] -= 1;

    emit WithdrawalHero(tokenId);
  }

  /**
    * @dev Pauses all token transfers.
    *
    * See {ERC721Pausable} and {Pausable-_pause}.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function pause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "NftUnit: must have pauser role to pause");
    _pause();
  }

  /**
    * @dev Unpauses all token transfers.
    *
    * See {ERC721Pausable} and {Pausable-_unpause}.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function unpause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "NftUnit: must have pauser role to unpause");
    _unpause();
  }

  /**
    * @dev Set NFT Heroes Coordinates Store contract address.
    *
    * See {UseGameHeroCoordinates}
    *
    * Requirements:
    *
    * - the caller must have the `ADMIN_ROLE`.
    */
  function setGameHeroCoordinatesStoreAddress(address contractAddress) public {
    require(hasRole(ADMIN_ROLE, _msgSender()), "GameSpawn: must have admin role to set contract address");
    _setGameHeroCoordinatesAddress(contractAddress);
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

  /**
    * @dev Private function to add a token to this extension's ownership-tracking data structures.
    * @param to address representing the new owner of the given token ID
    * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
      uint256 length = balanceOf(to);
      _ownedTokens[to][length] = tokenId;
      _ownedTokensIndex[tokenId] = length;
  }

  /**
    * @dev Private function to add a token to this extension's token tracking data structures.
    * @param tokenId uint256 ID of the token to be added to the tokens list
    */
  function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }

  /**
    * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
    * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
    * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
    * This has O(1) time complexity, but alters the order of the _ownedTokens array.
    * @param from address representing the previous owner of the given token ID
    * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
    */
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
    // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = balanceOf(from) - 1;
    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary
    if (tokenIndex != lastTokenIndex) {
      uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

      _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
      _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    }

    // This also deletes the contents at the last position of the array
    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];
  }

  /**
    * @dev Private function to remove a token from this extension's token tracking data structures.
    * This has O(1) time complexity, but alters the order of the _allTokens array.
    * @param tokenId uint256 ID of the token to be removed from the tokens list
    */
  function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
    // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = _allTokens.length - 1;
    uint256 tokenIndex = _allTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
    // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
    // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
    uint256 lastTokenId = _allTokens[lastTokenIndex];

    _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
    _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

    // This also deletes the contents at the last position of the array
    delete _allTokensIndex[tokenId];
    _allTokens.pop();
  }
}
