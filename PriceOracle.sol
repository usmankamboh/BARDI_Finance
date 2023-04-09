// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "./BToken.sol";
contract PriceOracle {
    // @notice Indicator that this is a PriceOracle contract (for inspection)
    bool public constant isPriceOracle = true;
    function getUnderlyingPrice(BToken bToken) external view returns (uint);
}
