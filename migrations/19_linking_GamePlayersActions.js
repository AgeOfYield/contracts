const contractsAddresses = require('../contractsAddresses.json')
const GamePlayersActions = artifacts.require('./GamePlayersActions.sol')
const GameSpawn = artifacts.require('./GameSpawn.sol')
const GamePay = artifacts.require('./GamePay.sol')
const NftHero = artifacts.require('./NftHero/NftHero.sol')
const HeroBalance = artifacts.require('./HeroBalance/HeroBalance.sol')
const GameHeroStamina = artifacts.require('./GameHeroStamina.sol')
const GameHeroCoordinates = artifacts.require('./GameHeroCoordinates.sol')

module.exports = async function(deployer) {
  const [
    gamePlayersActionsInstance,
    gameHeroCoordinatesInstance,
    gameSpawnInstance,
    gamePayInstance,
    nftHeroInstance,
    heroBalanceInstance,
    gameHeroStaminaInstance,
  ] = await Promise.all([
    GamePlayersActions.at(contractsAddresses.GamePlayersActions),
    GameHeroCoordinates.at(contractsAddresses.GameHeroCoordinates),
    GameSpawn.at(contractsAddresses.GameSpawn),
    GamePay.at(contractsAddresses.GamePay),
    NftHero.at(contractsAddresses.NftHero),
    HeroBalance.at(contractsAddresses.HeroBalance),
    GameHeroStamina.at(contractsAddresses.GameHeroStamina),
  ])

  deployer.logger.log('Contracts inited')

  await Promise.all([
    gamePlayersActionsInstance.setGameHeroCoordinatesAddress(gameHeroCoordinatesInstance.address),
    gamePlayersActionsInstance.setGameSpawnAddress(gameSpawnInstance.address),
    gamePlayersActionsInstance.setGamePayAddress(gamePayInstance.address),
    gamePlayersActionsInstance.setNftHeroAddress(nftHeroInstance.address),
    gamePlayersActionsInstance.setHeroBalanceAddress(heroBalanceInstance.address),
    gamePlayersActionsInstance.setGameHeroStaminaAddress(gameHeroStaminaInstance.address),
  ])

  deployer.logger.log('Contracts setted')

  const [
    GAME_ROLE,
    PAYMENT_ROLE,
    VIEWER_OF_CHARACTERISTICS,
    MOVE_BALANCE_ROLE,
    REDUCE_BALANCE_ROLE,
    STAMINA_SPENDER_ROLE,
  ] = await Promise.all([
    gameHeroCoordinatesInstance.GAME_ROLE(),
    gamePayInstance.PAYMENT_ROLE(),
    nftHeroInstance.VIEWER_OF_CHARACTERISTICS(),
    heroBalanceInstance.MOVE_BALANCE_ROLE(),
    heroBalanceInstance.REDUCE_BALANCE_ROLE(),
    gameHeroStaminaInstance.STAMINA_SPENDER_ROLE(),
  ])

  deployer.logger.log('Roles getted')

  await Promise.all([
    gameHeroCoordinatesInstance.grantRole(GAME_ROLE, gamePlayersActionsInstance.address),
    gamePayInstance.grantRole(PAYMENT_ROLE, gamePlayersActionsInstance.address),
    nftHeroInstance.grantRole(VIEWER_OF_CHARACTERISTICS, gamePlayersActionsInstance.address),
    heroBalanceInstance.grantRole(MOVE_BALANCE_ROLE, gamePlayersActionsInstance.address),
    heroBalanceInstance.grantRole(REDUCE_BALANCE_ROLE, gamePlayersActionsInstance.address),
    gameHeroStaminaInstance.grantRole(STAMINA_SPENDER_ROLE, gamePlayersActionsInstance.address),
  ])

  deployer.logger.log('Roles granted')
}
