// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "./BaseJumpRateModelV2.sol";
import "./InterestRateModel.sol";
contract JumpRateModelV2 is InterestRateModel, BaseJumpRateModelV2  {
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint) {
        return getBorrowRateInternal(cash, borrows, reserves);
    }

    constructor(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_, address owner_) 
    	BaseJumpRateModelV2(baseRatePerYear,multiplierPerYear,jumpMultiplierPerYear,kink_,owner_) public {}
}