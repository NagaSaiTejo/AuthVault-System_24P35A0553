const hre = require("hardhat");

async function main() {
  const [authority] = await hre.ethers.getSigners();

  const Auth = await hre.ethers.getContractFactory("AuthorizationManager");
  const auth = await Auth.deploy(authority.address);
  await auth.waitForDeployment();

  const Vault = await hre.ethers.getContractFactory("SecureVault");
  const vault = await Vault.deploy(await auth.getAddress());
  await vault.waitForDeployment();

  console.log("=================================");
  console.log("Network:", hre.network.name);
  console.log("Authority:", authority.address);
  console.log("AuthorizationManager:", await auth.getAddress());
  console.log("SecureVault:", await vault.getAddress());
  console.log("=================================");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
