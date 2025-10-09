// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

/**
 * @title StableCoim
 * @author Zero Web3
 */
import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ZeroEngine is ReentrancyGuard{


    error TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error NeedsMoreThanZero();
    error TokenNotAllowed(address token);
    error NotAllowedToken();
    error TransferFailed();
    error BreaksHealthFactor(uint256 healthFactorValue);
    error MintFailed();
    error HealthFactorOk();
    error HealthFactorNotImproved();

    StableCoin private immutable i_zero;
    mapping(address token => address priceFeed) private s_priceFeeds;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert NotAllowedToken();
        }
        _;
    }

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address zeroAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_zero = StableCoin(zeroAddress);
    }

    function depositCollateralAndMintZero() external {}
    

    function depositCollateral(address addressColateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(addressColateralAddress)
        nonReentrant
    {

    }

    function redeemCollateralForZero() external {}

    function redeemCollateral() external {}

    function mintZero() external {}

    function burnZero() external {}

    function liquidatte() external {}

    function getHealthFactor() external {}
}
