// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
contract InterestRateModel {
    // @notice Indicator that this is an InterestRateModel contract (for inspection)
    bool public constant isInterestRateModel = true;
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);

}
