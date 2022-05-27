// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
require("dotenv").config();

async function deploy(...args) {
  const ContractClass = await hre.ethers.getContractFactory("Element");
  const contractInst = await ContractClass.deploy(...args);

  await contractInst.deployed();

  const name = await contractInst.name();

  console.log(`${name} is deployed to: ${contractInst.address}`);

  {
    // test mint
    let tx = await contractInst.mint(process.env.GANACHE_PUBLIC_KEY, 100000)
    await tx.wait;

    let amount = await contractInst.balanceOf(process.env.GANACHE_PUBLIC_KEY)

    console.log(`${name}: mint ${amount} to ${process.env.GANACHE_PUBLIC_KEY}`);
  }
}

async function main() {
  await deploy("Primal Air", "AIR")
  await deploy("Primal Earth", "EARTH")
  await deploy("Primal Fire", "FIRE")
  await deploy("Primal Life", "LIFE")
  await deploy("Primal Might", "MIGHT")
  await deploy("Primal Water", "WATER")

  await deploy("Primal Mote", "MOTE")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
