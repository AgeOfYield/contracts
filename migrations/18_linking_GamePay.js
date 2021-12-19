const contractsAddresses = require('../contractsAddresses.json')
const GamePay = artifacts.require('./GamePay.sol')

module.exports = async function(deployer) {  
  const gamePayInstance = await GamePay.at(contractsAddresses.HeroBalance)
  deployer.logger.log('Contracts inited')

  await gamePayInstance.setAoyAddress(contractsAddresses.AgeOfYieldToken)
  deployer.logger.log('Token setted')
}
