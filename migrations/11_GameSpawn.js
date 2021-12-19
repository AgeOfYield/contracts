const saveContractAddress = require('../utils/saveContractAddress')
const GameSpawn = artifacts.require('./GameSpawn.sol')

module.exports = async function(deployer){
  await deployer.deploy(GameSpawn)
  const gameSpawnInstance = await GameSpawn.deployed()

  saveContractAddress('GameSpawn', gameSpawnInstance.address)
}
