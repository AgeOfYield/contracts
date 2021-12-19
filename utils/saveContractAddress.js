const fs = require('fs')
const path = require('path')

const filePath = path.join(__dirname, '../contractsAddresses.json')

module.exports = function saveContractAddress(name, address) {
  const addresses = JSON.parse(fs.readFileSync(filePath).toString())

  addresses[name] = address

  fs.writeFileSync(filePath, JSON.stringify(addresses))
}