// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

// exec: npx hardhat --network polygontestnet  run scripts/get_from_fauct.js
const hre = require("hardhat");
const Wallet = hre.ethers.Wallet;
const BigNumber = hre.ethers.BigNumber;
const utils = hre.ethers.utils;

require("dotenv").config();
const { exec } = require("child_process");

var sleep = require('sleep');

function os_func() {
    this.execCommand = function (cmd) {
        return new Promise((resolve, reject) => {
            exec(cmd, (error, stdout, stderr) => {
                if (error) {
                    reject(error);
                    return;
                }
                resolve(stdout)
            });
        })
    }
}

async function main() {
    const wallets = generate_wallets();

    for (const wallet of wallets) {
        await get_token_from_faucet(wallet);
        sleep.sleep(3);
    }

    console.log('sleep 60 for confirmation....')
    sleep.sleep(90); // 

    for (const wallet of wallets) {
        await transfer_to_main(wallet);
    }
}

function generate_wallets() {
    const loops = 20;
    const wallets = []

    const mnemonic = "office wing engine wide output execute butter until inch hobby cart hire undo burst whale"

    for (let i = 0; i < loops; i++) {
        walletInst = Wallet.fromMnemonic(mnemonic, `m/44'/60'/0'/0/${i}`)
        wallets.push(walletInst)
    }

    return wallets;
}

async function get_token_from_faucet(walletInst) {
    await walletInst.getAddress();

    console.log(`public key for wallet: ${walletInst.address}`)

    const cmd = `curl 'https://api.faucet.matic.network/transferTokens' \
        -H 'authority: api.faucet.matic.network' \
        -H 'accept: application/json, text/plain, */*' \
        -H 'accept-language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,id;q=0.6' \
        -H 'content-type: application/json;charset=UTF-8' \
        -H 'origin: https://faucet.polygon.technology' \
        -H 'referer: https://faucet.polygon.technology/' \
        -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="101", "Google Chrome";v="101"' \
        -H 'sec-ch-ua-mobile: ?0' \
        -H 'sec-ch-ua-platform: "macOS"' \
        -H 'sec-fetch-dest: empty' \
        -H 'sec-fetch-mode: cors' \
        -H 'sec-fetch-site: cross-site' \
        -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36' \
        --data-raw '{"network":"mumbai","address":"${walletInst.address}","token":"maticToken"}' \
        --compressed`

    const os = new os_func()
    return os.execCommand(cmd).then(res => {
        console.log("os >>>", res);
    }).catch(err => {
        console.log("os >>>", err);
    })
}

async function transfer_to_main(walletInst) {
    await walletInst.getAddress();

    walletInst = walletInst.connect(hre.ethers.provider)
    const balance = await walletInst.getBalance();
    const amount = balance.sub(utils.parseEther("0.01"))

    console.log(`balance of ${walletInst.address}: ${balance}`)
    if (!amount.gt(utils.parseEther("0.1"))) {
        console.log(`balance is not enough, abort`)
        return
    }

    const tx = {
        to: "0x5A99A8A5225EF3f589Ad94e2865ac30b7bBF61F3",
        value: amount
    }

    console.log(`tx: ${amount.toString()}`)

    const signedTx = await walletInst.signTransaction(tx)
    console.log(`signedTx: ${signedTx}`)

    const txRsp = await walletInst.sendTransaction(tx)
    const receipt = await txRsp.wait()
    console.log(`received: ${JSON.stringify(receipt,  null, '\t')}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
