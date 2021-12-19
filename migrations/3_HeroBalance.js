const saveContractAddress = require('../utils/saveContractAddress')
const HeroBalance = artifacts.require('./HeroBalance/HeroBalance.sol')

module.exports = async function(deployer){
  await deployer.deploy(HeroBalance)
  const heroBalanceInstance = await HeroBalance.deployed()

  saveContractAddress('HeroBalance', heroBalanceInstance.address)
}
