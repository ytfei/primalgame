// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function deploy(contractName) {
  const ContractClass = await hre.ethers.getContractFactory(contractName);
  const contractInst = await ContractClass.deploy();

  await contractInst.deployed();

  console.log(`${contractName} is deployed to: ${contractInst.address}`);
}

async function main() {
  const contractNames = ["Mote", "Earth", "Fire", "Life", "Water", "Air", "Might"]
  for (c of contractNames) {
    await deploy(c)
  }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
