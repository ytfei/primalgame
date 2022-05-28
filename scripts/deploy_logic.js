// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const utils = hre.ethers.utils;

const { assert } = require("chai");

async function deploy(contractName, ...args) {
  const ContractClass = await hre.ethers.getContractFactory(contractName);
  const contractInst = await ContractClass.deploy(...args);

  await contractInst.deployed();

  console.log(`${contractName} is deployed to: ${contractInst.address}`);

  return contractInst;
}

async function main() {

  // deploy 
  const primalData = await deploy('PrimalData');

  const primalNFT = await deploy('PrimalNFT', 'Primal Spirits', 'PSPT', "https://primal-5c2fd.web.app/metadata/", primalData.address); 

  let tx = await primalData.setNFTAddress(primalNFT.address);
  let txReceipt = await tx.wait();

  let nftAddress = await primalData.nftAddress();
  assert.equal(nftAddress, primalNFT.address); // check that

  // grant role 
  const roleName = utils.keccak256(utils.toUtf8Bytes("UPDATE_ROLE"));
  tx = await primalData.grantRole(roleName, primalNFT.address);
  txReceipt = await tx.wait();

  // const pveAddress = await deploy('PrimalPve', primalNFT.address, primalData.address);

  // const nftMining = await deploy('NFTMinging', primalNFT.address, primalData.address);


  // const rewardPoolAddress = await deploy('RewardPool', nftMiningAddress, 10, 0);
  // RewardPool is deployed by RewardPool while contructiing RewardPool

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
