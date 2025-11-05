// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test,console} from "forge-std/Test.sol";
import {ZeroEngine} from "../../src/ZeroEngine.sol";
import {StableCoin} from "../../src/StableCoin.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployZero} from "../../script/DeployZero.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";



contract InvariantTest is StdInvariant, Test {
    ZeroEngine engine;
    StableCoin stable;
    DeployZero deployZero;
    HelperConfig config;
    address weth;
    address wbtc;

    function setUp() public {
        deployZero = new DeployZero();
        (stable, engine, config) = deployZero.run();
        targetContract(address(engine));
        (,, weth, wbtc,) = config.activeNetworkConfig();
    }

    function invariant_protocolMustHaveMoreThanValueTotalSupply() public view {
        uint256 totalSupply = stable.totalSupply();
        uint256 totalWethDeposited= ERC20(weth).balanceOf(address(engine));
        uint256 totalWbtcDeposited= ERC20(wbtc).balanceOf(address(engine));

        uint256 ethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 btcValue = engine.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("Total Supply", totalSupply);
        console.log("Total ETH Value", ethValue);
        console.log("Total BTC Value", btcValue);

        assert(ethValue + btcValue >= totalSupply);
    
    }
}