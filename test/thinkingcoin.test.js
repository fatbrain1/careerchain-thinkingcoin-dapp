
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ThinkingCoin and CareerRewards Contracts", function () {
    let ThinkingCoin, CareerRewards, thinkingCoin, careerRewards;
    let owner, user1, user2;

    before(async function () {
        [owner, user1, user2] = await ethers.getSigners();

        // Deploy ThinkingCoin contract
        ThinkingCoin = await ethers.getContractFactory("ThinkingCoin");
        thinkingCoin = await ThinkingCoin.deploy();
        await thinkingCoin.deployed();

        // Deploy CareerRewards contract
        CareerRewards = await ethers.getContractFactory("CareerRewards");
        careerRewards = await CareerRewards.deploy(thinkingCoin.address);
        await careerRewards.deployed();
    });

    it("Should mint initial tokens to the owner", async function () {
        const ownerBalance = await thinkingCoin.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.utils.parseUnits("1000000", 18));
    });

    it("Should reward ⭐ Points to a user", async function () {
        await careerRewards.rewardStars(user1.address, 500);
        const points = await careerRewards.getStarPoints(user1.address);
        expect(points).to.equal(500);
    });

    it("Should convert ⭐ Points to ThinkingCoins", async function () {
        // Reward ⭐ Points to user1
        await careerRewards.rewardStars(user1.address, 500);

        // Convert ⭐ Points to ThinkingCoins
        await careerRewards.connect(user1).convertStarsToTokens();

        const userBalance = await thinkingCoin.balanceOf(user1.address);
        const remainingPoints = await careerRewards.getStarPoints(user1.address);

        // Check the user's token balance and remaining points
        expect(userBalance).to.equal(ethers.utils.parseUnits("5", 18)); // 500 / 100 = 5 tokens
        expect(remainingPoints).to.equal(0);
    });

    it("Should not allow conversion if insufficient ⭐ Points", async function () {
        await expect(
            careerRewards.connect(user2).convertStarsToTokens()
        ).to.be.revertedWith("No ⭐ Points to convert");
    });
});
