// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {ZeroEngine} from "../src/ZeroEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployZero is Script {
    address[] tokenAddresses;
    address[] priceFeedAddresses;

    function run() external returns (StableCoin, ZeroEngine, HelperConfig) {
        HelperConfig config = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployKey) =
            config.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployKey);
        StableCoin stable = new StableCoin();
        ZeroEngine zeroEngine = new ZeroEngine(tokenAddresses, priceFeedAddresses, address(stable));
        stable.transferOwnership(address(zeroEngine));
        vm.stopBroadcast();

        return (stable, zeroEngine, config);
    }
}
