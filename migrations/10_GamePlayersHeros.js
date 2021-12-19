const saveContractAddress = require('../utils/saveContractAddress')
const GamePlayersHeroes = artifacts.require('./GamePlayersHeroes.sol')

module.exports = async function(deployer){
  await deployer.deploy(GamePlayersHeroes)
  const GamePlayersHeroesInstance = await GamePlayersHeroes.deployed()

  saveContractAddress('GamePlayersHeroes', GamePlayersHeroesInstance.address)
}
