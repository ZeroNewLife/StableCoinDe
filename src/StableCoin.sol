// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StableCoim
 * @author Zero Web3
 * Collateral: Exogenous
 * Minting (Stability Mechanism): Decentralized (Algorithmic)
 * Value (Relative Stability): Anchored (Pegged to USD)
 * Collateral Type: Crypto
 */
contract StableCoin is ERC20Burnable, Ownable {
    error YourBalanceLessZero();
    error BurnAmountExedesBalance();
    error NotZeroAddress();
    error MastBeMoreThanZero();

    constructor() ERC20("ZERO", "Z") Ownable(msg.sender) {}

    // Тут у нас происходит сжигание монет
    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);

        if (_amount <= 0) {
            revert YourBalanceLessZero();
        }
        if (balance < _amount) {
            revert BurnAmountExedesBalance();
        }
        super.burn(_amount);
    }
    // Как бы логично что тут происходит минт монеток

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert NotZeroAddress();
        }
        if (_amount <= 0) {
            revert MastBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }

}
