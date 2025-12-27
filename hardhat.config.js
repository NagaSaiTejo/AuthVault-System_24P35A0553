require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    docker: {
      url: "http://blockchain:8545",
      chainId: 31337
    }
  }
};