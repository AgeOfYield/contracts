const contractsAddresses = require('../contractsAddresses.json')
const GameNftHeroCreator = artifacts.require('./GameNftHeroCreator.sol')
const NftHero = artifacts.require('./NftHero/NftHero.sol')
const GamePay = artifacts.require('./GamePay.sol')

module.exports = async function(deployer) {
  deployer.logger.log('Start')

  const [
    gameNftHeroCreatorInstance,
    nftHeroInstance,
    gamePayInstance
  ] = await Promise.all([
    GameNftHeroCreator.at(contractsAddresses.GameNftHeroCreator),
    NftHero.at(contractsAddresses.NftHero),
    GamePay.at(contractsAddresses.GamePay),
  ])

  deployer.logger.log('Contracts inited')

  await Promise.all([
    gameNftHeroCreatorInstance.setNftHeroAddress(contractsAddresses.NftHero),
    gameNftHeroCreatorInstance.setGamePayAddress(contractsAddresses.NftHero),
  ])

  deployer.logger.log('Contracts setted')

  const [MINTER_ROLE, PAYMENT_ROLE] = await Promise.all([
    nftHeroInstance.MINTER_ROLE(),
    gamePayInstance.PAYMENT_ROLE(),
  ])

  deployer.logger.log('Roles getted')

  await Promise.all([
    nftHeroInstance.grantRole(MINTER_ROLE, gameNftHeroCreatorInstance.address),
    gamePayInstance.grantRole(PAYMENT_ROLE, gameNftHeroCreatorInstance.address),
  ])

  deployer.logger.log('Roles granted')
}
