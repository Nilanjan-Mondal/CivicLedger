require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { CELO_RPC_URL, DEPLOYER_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 }
    }
  },
  networks: {
    celoSepolia: {
      url: CELO_RPC_URL,
      accounts: [DEPLOYER_PRIVATE_KEY],
      chainId: 11142220
    }
  }
};
