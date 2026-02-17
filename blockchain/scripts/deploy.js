const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const CivicLedger = await hre.ethers.getContractFactory("CivicLedger");

  // No manual gas override
  const contract = await CivicLedger.deploy(deployer.address);

  await contract.waitForDeployment();

  console.log("CivicLedger deployed to:", await contract.getAddress());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
