// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const utils = hre.ethers.utils;
require("dotenv").config();

// deploy resources
async function deploy(...args) {
  const ContractClass = await hre.ethers.getContractFactory("Element");
  const contractInst = await ContractClass.deploy(...args);

  await contractInst.deployed();

  const name = await contractInst.name();
  const symbol = await contractInst.symbol();

  // console.log(`${name} is deployed to: ${contractInst.address}`);
  console.log(`IERC20 public constant ${symbol} = IERC20(${contractInst.address});`);

  {
    // test mint
    let tx = await contractInst.mint(process.env.GANACHE_PUBLIC_KEY, utils.parseEther("1000000000"))
    await tx.wait;

    let amount = await contractInst.balanceOf(process.env.GANACHE_PUBLIC_KEY)

    // console.log(`${name}: mint ${amount} to ${process.env.GANACHE_PUBLIC_KEY}`);
  }

  return contractInst
}

async function main() {
  await deploy("Primal Air", "WIND")
  await deploy("Primal Earth", "EARTH")
  await deploy("Primal Fire", "FIRE")
  await deploy("Primal Life", "LIFE")
  await deploy("Primal Might", "SOURCE")
  await deploy("Primal Water", "WATER")

  await deploy("Primal Mote", "PRIMALCOIN")
}

module.exports.deploy = deploy;

// We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
