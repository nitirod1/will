import { HardhatUserConfig } from "hardhat/config";
import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";

// Template
const { SEPOLIA_RPC, PRIVATE_KEY, ETHERSCAN_API } = process.env;

const config: HardhatUserConfig = {
  networks: {
    sepolia: {
      url: SEPOLIA_RPC || "",
      accounts: [PRIVATE_KEY as string],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: (ETHERSCAN_API as string) || "",
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
};

export default config;
