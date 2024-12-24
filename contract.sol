// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TheUnlimitedCoin is ERC20 {
    // Constructor to mint an initial supply to the contract itself
    constructor() ERC20("TheUnlimitedCoin", "TUC") {
        _mint(address(this), 100000000000 * 10**18); // 
    }

    function claimTokens(uint256 amount) external {
        _transfer(address(this), msg.sender, amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract DiceRollGame {
    IERC20 public memeCoin; // The meme coin used for the game (TUC)
    uint256 public gameFee = 1 * 10**18; // Fee to play (1 TUC)
    uint256 public rewardAmount = 2 * 10**18; // Reward for a correct guess (2 TUC)

    // Events
    event GamePlayed(address indexed player, uint256 guess, uint256 rolledNumber, bool won);

    // Constructor to initialize the meme coin contract
    constructor(address _memeCoin) {
        memeCoin = IERC20(_memeCoin);
    }

    // Function to play the dice game
    function playGame(uint256 guess) external {
        require(guess >= 1 && guess <= 6, "Guess must be between 1 and 6.");
        
        // Transfer 1 TUC from the player to the contract
        require(memeCoin.transferFrom(msg.sender, address(this), gameFee), "Failed to pay game fee.");

        // Generate a random dice roll between 1 and 6
        uint256 rolledNumber = _rollDice();

        // If the player guessed correctly, transfer 2 TUC as reward
        bool won = false;
        if (guess == rolledNumber) {
            won = true;
            require(memeCoin.transfer(msg.sender, rewardAmount), "Reward transfer failed.");
        }

        // Emit the result of the game
        emit GamePlayed(msg.sender, guess, rolledNumber, won);
    }

    // Helper function to simulate dice roll
    function _rollDice() internal view returns (uint256) {
        // Using blockhash and block.timestamp to generate randomness (for test purposes)
        return (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 6) + 1;
    }

    // Function to fund the contract (admin or anyone with minting ability can fund)
    function fundContract(uint256 amount) external {
        require(memeCoin.transferFrom(msg.sender, address(this), amount), "Funding contract failed.");
    }
}
