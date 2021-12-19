const saveContractAddress = require('../utils/saveContractAddress')
const GameHeroStamina = artifacts.require('./GameHeroStamina.sol')

module.exports = async function(deployer){
  await deployer.deploy(GameHeroStamina)
  const gameHeroStaminaInstance = await GameHeroStamina.deployed()

  saveContractAddress('GameHeroStamina', gameHeroStaminaInstance.address)
}
