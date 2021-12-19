const contractsAddresses = require('../contractsAddresses.json')
const GameHeroStamina = artifacts.require('./GameHeroStamina.sol')
const NftHero = artifacts.require('./NftHero/NftHero.sol')

module.exports = async function(deployer) {
  const nftHeroInstance = await NftHero.at(contractsAddresses.NftHero)
  const gameHeroStaminaInstance = await GameHeroStamina.at(contractsAddresses.GameHeroStamina)

  await gameHeroStaminaInstance.setNftHeroAddress(contractsAddresses.NftHero)
  await gameHeroStaminaInstance.setGameSpawnAddress(contractsAddresses.GameSpawn)

  const VIEWER_OF_CHARACTERISTICS = await nftHeroInstance.VIEWER_OF_CHARACTERISTICS()

  await nftHeroInstance.grantRole(VIEWER_OF_CHARACTERISTICS, gameHeroStaminaInstance.address)
}
