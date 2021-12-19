const saveContractAddress = require('../utils/saveContractAddress')
const GameNftHeroCreator = artifacts.require('./GameNftHeroCreator.sol')

module.exports = async function(deployer){
  await deployer.deploy(GameNftHeroCreator)
  const GameNftHeroCreatorInstance = await GameNftHeroCreator.deployed()

  saveContractAddress('GameNftHeroCreator', GameNftHeroCreatorInstance.address)
}
