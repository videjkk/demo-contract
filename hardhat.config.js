require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

require("./task/subtasks");
require("./task/contract.deploy");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {version: "0.8.24"},
      {version: "0.7.6"},
    ],
  },
  networks: {
    testnet: {
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      url: `https://endpoints.omniatech.io/v1/eth/goerli/public`,
      gas: 6000000,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
