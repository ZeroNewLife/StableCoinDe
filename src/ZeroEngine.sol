// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

/**
 * @title StableCoim
 * @author Zero Web3
 */
import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ZeroEngine is ReentrancyGuard {


    ///////////////////
    // Errors
    ///////////////////

    error TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error NeedsMoreThanZero();
    error TokenNotAllowed(address token);
    error NotAllowedToken();
    error TransferFailed();
    error BreaksHealthFactor(uint256 healthFactorValue);
    error MintFailed();
    error HealthFactorOk();
    error HealthFactorNotImproved();

    ///////////////////
    // Events
    ///////////////////
    event collateralDeposited(address indexed user, address indexed tokenCollateral, uint256 amount);

    ///////////////////
    // State Variables
    ///////////////////

    StableCoin private immutable i_zero;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposit;

    ///////////////////
    // Modifiers
    ///////////////////

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

    ///////////////////
    // Functions
    ///////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address zeroAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_zero = StableCoin(zeroAddress);
    }



     ///////////////////
    // External Functions
    ///////////////////

    function depositCollateralAndMintZero() external {}

    function depositCollateral(address tokenColateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenColateralAddress)
        nonReentrant
    {
        s_collateralDeposit[msg.sender][tokenColateralAddress] += amountCollateral;
        emit collateralDeposited(msg.sender, tokenColateralAddress, amountCollateral);
        bool success = IERC20(tokenColateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert TransferFailed();
        }
    }

    function redeemCollateralForZero() external {}

    function redeemCollateral() external {}

    function mintZero() external {}

    function burnZero() external {}

    function liquidatte() external {}

    function getHealthFactor() external {}


}
