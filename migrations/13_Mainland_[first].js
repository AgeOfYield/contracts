const saveContractAddress = require('../utils/saveContractAddress')
const contractsAddresses = require('../contractsAddresses.json')
const Mainland = artifacts.require('./Mainland.sol')
const World = artifacts.require('./World.sol')

module.exports = async function(deployer){
  await deployer.deploy(Mainland, 1, 20, 20, 50)
  const mainlandInstance = await Mainland.deployed()
  const worldInstance = await World.at(contractsAddresses.World)

  await worldInstance.addMainland(mainlandInstance.address)

  saveContractAddress('Mainland1', mainlandInstance.address)
}
