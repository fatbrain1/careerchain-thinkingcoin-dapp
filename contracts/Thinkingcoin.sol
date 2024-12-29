
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ThinkingCoin is ERC20, Ownable {
    constructor() ERC20("ThinkingCoin", "THC") {
        // Mint initial supply to the contract owner
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    // Mint new tokens (can only be done by the owner)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}

2. CareerRewards Contract

This contract handles the ⭐ Points system, converting them to ThinkingCoins, and tracking rewards.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ThinkingCoin.sol";

contract CareerRewards {
    ThinkingCoin private thinkingCoin;

    // Mapping to store ⭐ Points for each user
    mapping(address => uint256) private starPoints;

    // Event to log rewards
    event RewardGiven(address indexed user, uint256 points);
    event StarsConverted(address indexed user, uint256 points, uint256 tokens);

    constructor(address thinkingCoinAddress) {
        thinkingCoin = ThinkingCoin(thinkingCoinAddress);
    }

    // Reward ⭐ Points to a user
    function rewardStars(address user, uint256 points) external {
        require(user != address(0), "Invalid user address");
        starPoints[user] += points;
        emit RewardGiven(user, points);
    }

    // View ⭐ Points for a user
    function getStarPoints(address user) external view returns (uint256) {
        return starPoints[user];
    }

    // Convert ⭐ Points to ThinkingCoins
    function convertStarsToTokens() external {
        uint256 points = starPoints[msg.sender];
        require(points > 0, "No ⭐ Points to convert");

        // Conversion logic (e.g., 1 THC = 100 ⭐ Points)
        uint256 tokens = points / 100;
        require(tokens > 0, "Not enough ⭐ Points to convert");

        // Update user points and transfer tokens
        starPoints[msg.sender] -= tokens * 100;
        thinkingCoin.mint(msg.sender, tokens * 10**thinkingCoin.decimals());
        emit StarsConverted(msg.sender, points, tokens);
    }
}

3. Deployment Script for Both Contracts

Create a file scripts/deploy.js for deployment:

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

