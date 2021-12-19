const contractsAddresses = require('../contractsAddresses.json')
const GameNftHeroCreator = artifacts.require('./GameNftHeroCreator.sol')
const GamePlayersActions = artifacts.require('./GamePlayersActions.sol')
const GameSpawn = artifacts.require('./GameSpawn.sol')
const GamePay = artifacts.require('./GamePay.sol')
const NftHero = artifacts.require('./NftHero/NftHero.sol')

module.exports = async function(deployer) {
  const [
    gameNftHeroCreatorInstance,
    gamePlayersActionsInstance,
    gameSpawnInstance,
    gamePayInstance,
    nftHeroInstance,
  ] = await Promise.all([
    GameNftHeroCreator.at(contractsAddresses.GameNftHeroCreator),
    GamePlayersActions.at(contractsAddresses.NftHero),
    GameSpawn.at(contractsAddresses.GameSpawn),
    GamePay.at(contractsAddresses.GamePay),
    NftHero.at(contractsAddresses.NftHero),
  ])

  deployer.logger.log('Contracts inited')

  await Promise.all([
    gameNftHeroCreatorInstance.unpause(),
    gamePlayersActionsInstance.unpause(),
    gameSpawnInstance.unpause(),
    gamePayInstance.unpause(),
    nftHeroInstance.unpause(),
  ])

  deployer.logger.log('Contracts unpaused')
}