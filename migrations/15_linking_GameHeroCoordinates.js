const contractsAddresses = require('../contractsAddresses.json')
const GameHeroCoordinates = artifacts.require('./GameHeroCoordinates.sol')

module.exports = async function(deployer) {
  const gameHeroCoordinatesInstance = await GameHeroCoordinates.at(contractsAddresses.GameHeroCoordinates)

  await gameHeroCoordinatesInstance.setWorldAddress(contractsAddresses.World)
}
