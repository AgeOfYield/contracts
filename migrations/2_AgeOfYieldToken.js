const saveContractAddress = require('../utils/saveContractAddress')
const AgeOfYieldToken = artifacts.require('./AgeOfYieldToken/AgeOfYieldToken.sol')

module.exports = async function(deployer){
  await deployer.deploy(AgeOfYieldToken)
  const ageOfYieldTokenInstance = await AgeOfYieldToken.deployed()

  saveContractAddress('AgeOfYieldToken', ageOfYieldTokenInstance.address)
}
