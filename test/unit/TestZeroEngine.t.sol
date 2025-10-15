// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {ZeroEngine} from "../../src/ZeroEngine.sol";
import {StableCoin} from "../../src/StableCoin.sol";
import {DeployZero} from "../../script/DeployZero.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../../test/mock/ERC20Mock.sol";

contract TestZeroEngine is Test {
    ZeroEngine engine;
    StableCoin stable;
    DeployZero deploy;
    HelperConfig config;
    address ethUsdPrice;
    address weth;

    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    address public USER = makeAddr("user");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        deploy = new DeployZero();
        (stable, engine, config) = deploy.run();
        (ethUsdPrice,, weth,,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);
    }

    function testGetUsdValue() public view {
        uint256 ethAmount = 15e18;

        uint256 expectedUsd = 30000e18;

        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);

        assertEq(expectedUsd, actualUsd);
    }

    function testCollateralRevertDeposited() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(ZeroEngine.NeedsMoreThanZero.selector);

        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
