const { task } = require("hardhat/config");
const {delay} = require("../helpers");

task("deploy:contracts", "Deploys swap and keystore contracts").setAction(async (taskArgs, hre) => {
    await hre.run("clean&compile");
    const keyStoreArguments = ["0x123412"]
    const KeyStore = await hre.run("deployment", {
        network: hre.network.name,
        arguments: keyStoreArguments,
        contract: "KeyStore",
    });
    const keyStoreAddress = await KeyStore.getAddress()
    await delay(20000);

    await hre.run("verification", {
        contract: "KeyStore",
        address: keyStoreAddress,
        constructorArguments: keyStoreArguments,
    });

    const SwapArguments = ["0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45", "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6", keyStoreAddress]
    const SwapContract = await hre.run("deployment", {
        network: hre.network.name,
        arguments: SwapArguments,
        contract: "Swap",
    });
    
    const swapContractAddress = await SwapContract.getAddress();
    await delay(20000);

    await hre.run("verification", {
        contract: "Swap",
        address: swapContractAddress,
        constructorArguments: SwapArguments,
    });
});
