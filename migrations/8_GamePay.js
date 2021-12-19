const saveContractAddress = require('../utils/saveContractAddress')
const GamePay = artifacts.require('./GamePay.sol')

module.exports = async function(deployer){
  await deployer.deploy(GamePay)
  const gamePayInstance = await GamePay.deployed()

  saveContractAddress('GamePay', gamePayInstance.address)
}
