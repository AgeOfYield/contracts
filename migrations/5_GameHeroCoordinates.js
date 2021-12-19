const saveContractAddress = require('../utils/saveContractAddress')
const GameHeroCoordinates = artifacts.require('./GameHeroCoordinates.sol')

module.exports = async function(deployer){
  await deployer.deploy(GameHeroCoordinates)
  const gameHeroCoordinatesInstance = await GameHeroCoordinates.deployed()

  saveContractAddress('GameHeroCoordinates', gameHeroCoordinatesInstance.address)
}
