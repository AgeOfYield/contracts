const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const path = require('path');
const testnetMnemonic = fs.readFileSync(path.join(__dirname, './.secret/testnet.secret')).toString().trim();
const localMnemonic = fs.readFileSync(path.join(__dirname, './.secret/local.secret')).toString().trim();

// 'https://bsc.getblock.io/testnet/?api_key=b4bc2b22-f208-4279-85ad-7164fbe7caf1';
// 'wss://bsc.getblock.io/testnet/?api_key=b4bc2b22-f208-4279-85ad-7164fbe7caf1'
// 'https://speedy-nodes-nyc.moralis.io/0580d6d62062ae83acf4c27e/bsc/testnet'
module.exports = {
  contracts_directory: path.join(__dirname, 'contracts'),
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    testnet: {
      provider: () => new HDWalletProvider(testnetMnemonic, `https://speedy-nodes-nyc.moralis.io/0580d6d62062ae83acf4c27e/bsc/testnet`),
      network_id: 97,
      // confirmations: 2,
      deploymentPollingInterval: 500000000,
      skipDryRun: true,
      networkCheckTimeout : 10000000, 
      timeoutBlocks : 20000 
    },
    local: {
      provider: () => new HDWalletProvider(localMnemonic, `http://127.0.0.1:7545`),
      network_id: 5777,
      confirmations: 0,
      deploymentPollingInterval: 100000,
      skipDryRun: true,
      timeoutBlocks: 4000 , 
      networkCheckTimeout : 10000000,
    },
    bsc: {
      provider: () => new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    useColors: true,
    timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.8.7", // A version or constraint - Ex. "^0.5.0"
      settings: {
        optimizer: {
          enabled: true,
          runs: 1000,   // Optimize for how many times you intend to run the code
        },
        evmVersion: 'istanbul'
      },
    }
  }
}