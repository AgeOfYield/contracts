const saveContractAddress = require('../utils/saveContractAddress')
const GamePlayersActions = artifacts.require('./GamePlayersActions.sol')

module.exports = async function(deployer){
  await deployer.deploy(GamePlayersActions)
  const gamePlayersActionsInstance = await GamePlayersActions.deployed()

  saveContractAddress('GamePlayersActions', gamePlayersActionsInstance.address)
}
