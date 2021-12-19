const saveContractAddress = require('../utils/saveContractAddress')
const NftHero = artifacts.require('./NftHero/NftHero.sol')

module.exports = async function(deployer){
  await deployer.deploy(NftHero, 'Age of Yield - HERO', 'AOY_HERO', 'http://localhost:3000/nft/hero')
  const nftHeroInstance = await NftHero.deployed()

  saveContractAddress('NftHero', nftHeroInstance.address)
}
