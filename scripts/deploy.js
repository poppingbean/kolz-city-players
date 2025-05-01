const hre = require("hardhat");

async function main() {
  const PlayerRegistry = await hre.ethers.getContractFactory("KOLZPlayerRegistry");
  const playerRegistry = await PlayerRegistry.deploy();

  await playerRegistry.waitForDeployment();

  console.log("KOLZPlayerRegistry deployed to:", await playerRegistry.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
