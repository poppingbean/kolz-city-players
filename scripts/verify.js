const hre = require("hardhat");

async function main() {
  await hre.run("verify:verify", {
    address: "0x33af87a47c07858e4787103928b0aef33d0a8bf2",
    constructorArguments: []
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
