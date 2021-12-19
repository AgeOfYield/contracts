const saveContractAddress = require('../utils/saveContractAddress')
const World = artifacts.require('./World.sol')

module.exports = async function(deployer){
  await deployer.deploy(World)
  const worldInstance = await World.deployed()

  saveContractAddress('World', worldInstance.address)
}
