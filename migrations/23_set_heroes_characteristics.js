const contractsAddresses = require('../contractsAddresses.json')
const NftHero = artifacts.require('./NftHero/NftHero.sol')
const GameNftHeroCreator = artifacts.require('./GameNftHeroCreator.sol')

module.exports = async function(deployer) {
  const [nftHeroInstance, gameNftHeroCreatorInstance] = await Promise.all([
    NftHero.at(contractsAddresses.NftHero),
    GameNftHeroCreator.at(contractsAddresses.GameNftHeroCreator),
  ])

  deployer.logger.log('Contracts inited')

  const divisorOfCharacteristics = await nftHeroInstance.divisorOfCharacteristics()

  deployer.logger.log('Decimals getted')

  await Promise.all([
    gameNftHeroCreatorInstance.setInitialCharacteristics(
      0,
      {
        attack: divisorOfCharacteristics * 1000,
        defense: divisorOfCharacteristics * 1000,
        mining: divisorOfCharacteristics * 1000,
        capacity: divisorOfCharacteristics * 1000,
        stamina: divisorOfCharacteristics * 1000,
        fortune: divisorOfCharacteristics * 1000,
        exists: true,
      }
    ),
    gameNftHeroCreatorInstance.setInitialCharacteristics(
      1,
      {
        attack: divisorOfCharacteristics * 1500,
        defense: divisorOfCharacteristics * 500,
        mining: divisorOfCharacteristics * 500,
        capacity: divisorOfCharacteristics * 1500,
        stamina: divisorOfCharacteristics * 1500,
        fortune: divisorOfCharacteristics * 1000,
        exists: true,
      }
    ),
    gameNftHeroCreatorInstance.setInitialCharacteristics(
      2,
      {
        attack: divisorOfCharacteristics * 1000,
        defense: divisorOfCharacteristics * 1500,
        mining: divisorOfCharacteristics * 1500,
        capacity: divisorOfCharacteristics * 1000,
        stamina: divisorOfCharacteristics * 500,
        fortune: divisorOfCharacteristics * 1000,
        exists: true,
      }
    ),
    gameNftHeroCreatorInstance.setInitialCharacteristics(
      3,
      {
        attack: divisorOfCharacteristics * 1100,
        defense: divisorOfCharacteristics * 1100,
        mining: divisorOfCharacteristics * 1100,
        capacity: divisorOfCharacteristics * 1100,
        stamina: divisorOfCharacteristics * 500,
        fortune: divisorOfCharacteristics * 1100,
        exists: true,
      }
    ),
    gameNftHeroCreatorInstance.setFactionMulCharacteristics(
      0,
      {
        attack: divisorOfCharacteristics * 1.1,
        defense: divisorOfCharacteristics * 0.9,
        mining: divisorOfCharacteristics * 0.9,
        capacity: divisorOfCharacteristics * 0.3,
        stamina: divisorOfCharacteristics * 1.1,
        fortune: divisorOfCharacteristics * 1,
        exists: true,
      }
    ),
    gameNftHeroCreatorInstance.setFactionMulCharacteristics(
      1,
      {
        attack: divisorOfCharacteristics * 0.9,
        defense: divisorOfCharacteristics * 1.2,
        mining: divisorOfCharacteristics * 1.3,
        capacity: divisorOfCharacteristics * 1.3,
        stamina: divisorOfCharacteristics * 1.1,
        fortune: divisorOfCharacteristics * 1.5,
        exists: true,
      }
    )
  ])

  deployer.logger.log('Characteristics setted')
}
