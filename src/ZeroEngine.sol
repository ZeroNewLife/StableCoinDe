// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

/**
 * @title StableCoim
 * @author Zero Web3
 */
import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract ZeroEngine is ReentrancyGuard {
    ///////////////////
    // error
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
    address[] s_collateralTokens;
    uint256 private constant ADDITIONAl_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MINT_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposit;
    mapping(address user => uint256 amount) private s_mintZero;

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
            s_collateralTokens.push(tokenAddresses[i]);
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

    function mintZero(uint256 amountMint) external moreThanZero(amountMint) nonReentrant {
        s_mintZero[msg.sender] += amountMint;
        _revertHealthFactorIsBroken(msg.sender);
        bool minted = i_zero.mint(msg.sender, amountMint);
        if (!minted) {
            revert MintFailed();
        }
    }

    function burnZero() external {}

    function liquidatte() external {}

    function getHealthFactor() external {}

    //тут у нас будет мини проверка если сумма юзера упадет ниже чем обычно то будет ликвидация
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalZeroMinter, uint256 collateralValueUsd) = _getAccountInformation(user);
        //пример того что здесь происходит например collateralValue ровна 1000 эфир умножая на 50
        //мы получаем 500000 а делим и получаем 500 тобиж потом просто  если чувака цена опустит ниже нужного ликвидация
        uint256 collateralForThreshold = (collateralValueUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralForThreshold * PRECISION) / totalZeroMinter;
    }

    function _revertHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MINT_HEALTH_FACTOR) {
            revert BreaksHealthFactor(userHealthFactor);
        }
    }

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalZeroMinter, uint256 collateralValueUst)
    {
        totalZeroMinter = s_mintZero[user];
        collateralValueUst = getAccountCollateralValue(user);
    }

    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueUsd) {
        for (uint256 i = 0; s_collateralTokens.length > 0; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposit[user][token];
            totalCollateralValueUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();

        // 1 ethereum 1000$
        // чтобы получит нам надо 1000 *1e8
        return ((uint256(price) * ADDITIONAl_FEED_PRECISION) * amount) / PRECISION;
        //PRECISION=1e18
        //ADDITIONAl_FEED_PRECISION=1e10
    }
}
