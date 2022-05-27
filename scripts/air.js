// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const BigNumber = hre.ethers.BigNumber;

require("dotenv").config();

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Wind = await hre.ethers.getContractFactory("Air");
  const wind = await Wind.attach(process.env.WIND_ADDRESS);

  const name = await wind.name();
  const totalSupply = await wind.totalSupply();

  console.log(`Total Supply of [${name}] is ${totalSupply}`);

  const address = process.env.USER_ADDRESS_1;
  await balanceOf(wind, address);

  const amount = BigNumber.from("100000");
  const tx = await wind.mint(address, amount);
  const result = await tx.wait();
  console.log(`Result: ${result}`)

  await balanceOf(wind, address);
}

async function balanceOf(wind, address) {
  const balance = await wind.balanceOf(address);
  console.log(`Balance of [${address}] is ${balance}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
