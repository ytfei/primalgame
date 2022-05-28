const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

const utils = ethers.utils;

async function deploy(contractName, ...args) {
  const ContractClass = await hre.ethers.getContractFactory(contractName);
  const contractInst = await ContractClass.deploy(...args);

  await contractInst.deployed();

  console.log(`${contractName} is deployed to: ${contractInst.address}`);

  return contractInst;
}

describe("NFTMining deploy case", function () {
  it("Should return the new greeting once it's changed", async function () {
    // deploy 
    const primalData = await deploy('PrimalData');

    const primalNFT = await deploy('PrimalNFT', 'Primal Spirits', 'PSPT', "https://primal-5c2fd.web.app/metadata/", primalData.address);

    let tx = await primalData.setNFTAddress(primalNFT.address);
    let txReceipt = await tx.wait();

    let nftAddress = await primalData.nftAddress();
    assert.equal(nftAddress, primalNFT.address); // check that

    // grant role 
    const roleName = utils.id("UPDATE_ROLE");// equal utils.keccak256(utils.toUtf8Bytes("UPDATE_ROLE"));
    tx = await primalData.grantRole(roleName, primalNFT.address);
    txReceipt = await tx.wait();

    console.log('begin to deply NFTMining and transfer tokens')
    const nftMining = await deploy('NFTMining', primalNFT.address, primalData.address);



    // expect(await greeter.greet()).to.equal("Hello, world!");

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
