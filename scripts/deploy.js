const hre = require("hardhat");

async function main() {
    // Deploy ThinkingCoin
    const ThinkingCoin = await hre.ethers.getContractFactory("ThinkingCoin");
    const thinkingCoin = await ThinkingCoin.deploy();
    await thinkingCoin.deployed();
    console.log("ThinkingCoin deployed to:", thinkingCoin.address);

    // Deploy CareerRewards
    const CareerRewards = await hre.ethers.getContractFactory("CareerRewards");
    const careerRewards = await CareerRewards.deploy(thinkingCoin.address);
    await careerRewards.deployed();
    console.log("CareerRewards deployed to:", careerRewards.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
