const contractsAddresses = require('../contractsAddresses.json')
const GamePlayersHeroes = artifacts.require('./GamePlayersHeroes.sol')
const GameHeroCoordinates = artifacts.require('./GameHeroCoordinates.sol')
const GameSpawn = artifacts.require('./GameSpawn.sol')
const NftHero = artifacts.require('./NftHero/NftHero.sol')
const HeroBalance = artifacts.require('./HeroBalance/HeroBalance.sol')

module.exports = async function(deployer) {
  const [
    GamePlayersHeroesInstance,
    gameHeroCoordinatesInstance,
    gameSpawnInstance,
    heroBalanceInstance,
    nftHeroInstance
  ] = await Promise.all([
    GamePlayersHeroes.at(contractsAddresses.GamePlayersHeroes),
    GameHeroCoordinates.at(contractsAddresses.GameHeroCoordinates),
    GameSpawn.at(contractsAddresses.GameSpawn),
    HeroBalance.at(contractsAddresses.HeroBalance),
    NftHero.at(contractsAddresses.NftHero),
  ])

  deployer.logger.log('Contracts inited')

  await Promise.all([
    GamePlayersHeroesInstance.setGameHeroCoordinatesAddress(gameHeroCoordinatesInstance.address),
    GamePlayersHeroesInstance.setGameSpawnAddress(gameSpawnInstance.address),
    GamePlayersHeroesInstance.setHeroBalanceAddress(heroBalanceInstance.address),
    GamePlayersHeroesInstance.setNftHeroAddress(nftHeroInstance.address),
  ])

  deployer.logger.log('Contracts setted')

  const [
    GAME_ROLE,
    BALANCE_VIEWER_ROLE,
    DEPOSIT_ROLE,
    WITHDRAWAL_ROLE,
    CAPACITY_VIEWER_ROLE,
    VIEWER_OF_CHARACTERISTICS,
  ] = await Promise.all([
    gameHeroCoordinatesInstance.GAME_ROLE(),
    heroBalanceInstance.BALANCE_VIEWER_ROLE(),
    heroBalanceInstance.DEPOSIT_ROLE(),
    heroBalanceInstance.WITHDRAWAL_ROLE(),
    heroBalanceInstance.CAPACITY_VIEWER_ROLE(),
    nftHeroInstance.VIEWER_OF_CHARACTERISTICS(),
  ])

  deployer.logger.log('Roles getted')

  await Promise.all([
    gameHeroCoordinatesInstance.grantRole(GAME_ROLE, GamePlayersHeroesInstance.address),
    heroBalanceInstance.grantRole(BALANCE_VIEWER_ROLE, GamePlayersHeroesInstance.address),
    heroBalanceInstance.grantRole(DEPOSIT_ROLE, GamePlayersHeroesInstance.address),
    heroBalanceInstance.grantRole(WITHDRAWAL_ROLE, GamePlayersHeroesInstance.address),
    heroBalanceInstance.grantRole(CAPACITY_VIEWER_ROLE, GamePlayersHeroesInstance.address),
    nftHeroInstance.grantRole(VIEWER_OF_CHARACTERISTICS, GamePlayersHeroesInstance.address),
  ])

  deployer.logger.log('Roles granted')
}
