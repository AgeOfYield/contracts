const contractsAddresses = require('../contractsAddresses.json')
const HeroBalance = artifacts.require('./HeroBalance/HeroBalance.sol')

const GamePay = artifacts.require('./GamePay.sol')
const GameSpawn = artifacts.require('./GameSpawn.sol')
const NftHero = artifacts.require('./NftHero/NftHero.sol')

module.exports = async function(deployer) {
  const [
    heroBalanceInstance,
    gamePayInstance,
    nftHeroInstance,
    gameSpawnInstance,
  ] = await Promise.all([
    HeroBalance.at(contractsAddresses.HeroBalance),
    GamePay.at(contractsAddresses.GamePay),
    NftHero.at(contractsAddresses.NftHero),
    GameSpawn.at(contractsAddresses.GameSpawn)
  ])
  
  console.log(1)
  await Promise.all([
    heroBalanceInstance.setGamePayAddress(gamePayInstance.address),
    heroBalanceInstance.setGameSpawnAddress(gameSpawnInstance.address),
    heroBalanceInstance.setNftHeroAddress(nftHeroInstance.address),
    heroBalanceInstance.setAoyAddress(contractsAddresses.AgeOfYieldToken)
  ])
  console.log(2)

  const [PAYMENT_ROLE, VIEWER_OF_CHARACTERISTICS] = await Promise.all([
    gamePayInstance.PAYMENT_ROLE(),
    nftHeroInstance.VIEWER_OF_CHARACTERISTICS(),
  ])
  console.log(3)

  await Promise.all([
    gamePayInstance.grantRole(PAYMENT_ROLE, heroBalanceInstance.address),
    nftHeroInstance.grantRole(VIEWER_OF_CHARACTERISTICS, heroBalanceInstance.address),
  ])
}
