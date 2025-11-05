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
    address btcUsdPrice;
    address weth;

    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    address public USER = makeAddr("user");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        deploy = new DeployZero();
        (stable, engine, config) = deploy.run();
        (ethUsdPrice, btcUsdPrice, weth,,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);
    }
    address[] public tokenAddreses;
    address[] public priceFeedAddreses;

    function testRevertIfTokenLengthMatchPriceFeed() public {
        tokenAddreses.push(weth);
        priceFeedAddreses.push(ethUsdPrice);
        priceFeedAddreses.push(btcUsdPrice);

        vm.expectRevert(ZeroEngine.TokenAddressesAndPriceFeedAddressesAmountsDontMatch.selector);
        new ZeroEngine(tokenAddreses, priceFeedAddreses, address(stable));
    }

    function testRevertUnUprovedCollateral() public {
        ERC20Mock erc = new ERC20Mock("ZERO", "ZERO", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(ZeroEngine.NotAllowedToken.selector);
        engine.depositCollateral(address(erc), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    function testGetUsdValue() public view {
        uint256 ethAmount = 15e18;

        uint256 expectedUsd = 30000e18;

        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);

        assertEq(expectedUsd, actualUsd);
    }

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmount = 100 ether;

        uint256 expectedEth = 0.05 ether;

        uint256 actualEth = engine.getTokenAmountFromUsd(weth, usdAmount);

        assertEq(expectedEth, actualEth);
    }

    function testCollateralRevertDeposited() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(ZeroEngine.NeedsMoreThanZero.selector);

        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
