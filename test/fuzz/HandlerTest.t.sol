// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Test, console} from "forge-std/Test.sol";
import {ZeroEngine} from "../../src/ZeroEngine.sol";
import {StableCoin} from "../../src/StableCoin.sol";
import {ERC20Mock} from "../mock/ERC20Mock.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.sol";

contract Handler is Test {
    ZeroEngine engine;
    StableCoin stable;
    ERC20Mock weth;
    ERC20Mock wbtc;
    MockV3Aggregator ethUsdPriceFeed;

    uint256 public timesMintIsCalled;
    address[] public userWithCollateralDeposited;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(ZeroEngine _engine, StableCoin _stable) {
        engine = _engine;
        stable = _stable;
        address[] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(engine.getCollateralTokenPriceFeed(address(weth)));
    }

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(engine), amountCollateral);
        engine.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();

        userWithCollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateral = engine.getCollateralBalanceOfUser(address(collateral), msg.sender);
        amountCollateral = bound(amountCollateral, 0, maxCollateral);
        if (amountCollateral == 0) {
            return;
        }
        engine.redeemCollateral(address(collateral), amountCollateral);
    }

    function mintZero(uint256 amount, uint256 addressSeed) public {
        if (userWithCollateralDeposited.length == 0) {
            return;
        }
        address sender = userWithCollateralDeposited[addressSeed % userWithCollateralDeposited.length];
        (uint256 totalZeroMinter, uint256 collateralValueUst) = engine.getAccountInformation(sender);
        int256 maxZeroToMint = (int256(collateralValueUst) / 2) - int256(totalZeroMinter);
        if (maxZeroToMint < 0) {
            return;
        }
        amount = bound(amount, 0, uint256(maxZeroToMint));
        if (amount == 0) {
            return;
        }
        vm.startPrank(sender);
        engine.mintZero(amount);
        vm.stopPrank();
        timesMintIsCalled += 1;
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth; //WETH
        } else {
            return wbtc; //WBTC
        }
    }

    // function updateCollateralPrice(uint96 newPrice) public{
    //     int256 ethPriced= int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(ethPriced);
    //     console.log("New ETH price is :", ethPriced);
    // }

    function invariant_getShouldNotRevert() public view {
        engine.getLiquidationBonus();
        engine.getPrecision();
    }
}
