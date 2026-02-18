require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

const { CELO_RPC_URL, DEPLOYER_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
  networks: {
    celoSepolia: {
      url: CELO_RPC_URL,
      accounts: [DEPLOYER_PRIVATE_KEY],
      chainId: 11142220,
    },
  },

  etherscan: {
    apiKey: {
      celoSepolia: "empty", // Blockscout doesn't require a real key
    },
    customChains: [
      {
        network: "celoSepolia",
        chainId: 11142220,
        urls: {
          apiURL: "https://celo-sepolia.blockscout.com/api",
          browserURL: "https://celo-sepolia.blockscout.com",
        },
      },
    ],
  },
};
