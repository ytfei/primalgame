// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const utils = hre.ethers.utils;

const { assert } = require("chai");

const { deploy: deploy_elements } = require("./deploy_elements.js");
require("dotenv").config();

async function deploy(contractName, ...args) {
  const ContractClass = await hre.ethers.getContractFactory(contractName);
  const contractInst = await ContractClass.deploy(...args);

  await contractInst.deployed();

  console.log(`${contractName} is deployed to: ${contractInst.address}`);

  return contractInst;
}

async function deployWithLib(contractName, libAddress, ...args) {
  const ContractClass = await hre.ethers.getContractFactory(contractName, {
    libraries: {
      LibUintSet: libAddress,
    },
  });
  const contractInst = await ContractClass.deploy(...args);

  await contractInst.deployed();

  console.log(`${contractName} is deployed to: ${contractInst.address}`);

  return contractInst;
}

async function grantUpdateRole(primalData, contractAddress) {
  const roleName = utils.id("UPDATE_ROLE");// equal utils.keccak256(utils.toUtf8Bytes("UPDATE_ROLE"));
  const tx = await primalData.grantRole(roleName, contractAddress);
  await tx.wait();
}

async function mintTo(elementName, elementAddress, contractAddress, amount) {
  const Element = await hre.ethers.getContractFactory("Element");
  const inst = await Element.attach(elementAddress);

  let tx = await inst.mint(contractAddress, amount);
  const receipt = await tx.wait();

  console.log(`mint resource ${elementName} from ${elementAddress} to ${contractAddress} with ${amount}`);
}

async function main() {

  const provider = hre.ethers.provider;
  console.log(`${JSON.stringify(hre.config, "", "\t")} ||| ${JSON.stringify(provider)}`)

  const signer = provider.getSigner();
  console.log(`${await signer.getAddress()} = ${await signer.getBalance()}`)

  // deploy 
  const primalData = await deploy('PrimalData');

  const primalNFT = await deploy('PrimalNFT', 'Primal Spirits', 'PSPT', "https://primal-game.web.app/metadata/", primalData.address);

  let tx = await primalData.setNFTAddress(primalNFT.address);
  let txReceipt = await tx.wait();

  let nftAddress = await primalData.nftAddress();
  assert.equal(nftAddress, primalNFT.address); // check that

  console.log('begin to deply NFTMining and transfer tokens')
  const nftMining = await deploy('NFTMining', primalNFT.address, primalData.address, { gasLimit: 6721970 });

  console.log('setup reward pool')
  tx = await nftMining.setUpRewardPool()
  txReceipt = await tx.wait()

  console.log('begin to deploy PrimalPve')
  const libUintSet = await deploy('LibUintSet');
  const primalPve = await deployWithLib('PrimalPve', libUintSet.address, primalNFT.address, primalData.address);

  console.log('begin to deploy UpdatePrimalData')
  const updatePrimalData = await deploy('UpdatePrimalData', primalNFT.address, primalData.address, primalPve.address);

  console.log('grant UPDATE_ROLE privilege to system contracts')
  await grantUpdateRole(primalData, primalNFT.address)
  await grantUpdateRole(primalData, nftMining.address);
  await grantUpdateRole(primalData, primalPve.address);
  await grantUpdateRole(primalData, updatePrimalData.address);

  // deploy and mint resources to contracts
  const elements =
    [
      ["Primal Air", "WIND"],
      ["Primal Earth", "EARTH"],
      ["Primal Fire", "FIRE"],
      ["Primal Life", "LIFE"],
      ["Primal Might", "SOURCE"],
      ["Primal Water", "WATER"],

      ["Primal Mote", "PRIMALCOIN"]
    ];

  for (let ele of elements) {
    const eleInst = await deploy_elements(ele[0], ele[1]);

    console.log(`mint [${ele[0]}] resources for system contracts`)
    await mintTo(ele[0], eleInst.address, nftMining.address, utils.parseEther("1000"))
    await mintTo(ele[0], eleInst.address, primalPve.address, utils.parseEther("1000"))
  }

  // mint NFT to Pve as monsters
  console.log('mint NFT to primalPve')
  for (var i = 0; i < 10; i++) {
    tx = await primalNFT.mint(primalPve.address, i, "https://primal-5c2fd.web.app/metadata/");
    await tx.wait();
  }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
