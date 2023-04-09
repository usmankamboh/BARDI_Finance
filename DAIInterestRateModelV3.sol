// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "./JumpRateModelV2.sol";
import "./SafeMath.sol";
contract DAIInterestRateModelV3 is JumpRateModelV2 {
    using SafeMath for uint;
    uint public gapPerBlock;
    uint public constant assumedOneMinusReserveFactorMantissa = 0.95e18;
    PotLike pot;
    JugLike jug;
    constructor(uint jumpMultiplierPerYear, uint kink_, address pot_, address jug_, address owner_) JumpRateModelV2(0, 0, jumpMultiplierPerYear, kink_, owner_) public {
        gapPerBlock = 4e16 / blocksPerYear;
        pot = PotLike(pot_);
        jug = JugLike(jug_);
        poke();
    }
    function updateJumpRateModel(uint baseRatePerYear, uint gapPerYear, uint jumpMultiplierPerYear, uint kink_) external {
        require(msg.sender == owner, "only the owner may call this function.");
        gapPerBlock = gapPerYear / blocksPerYear;
        updateJumpRateModelInternal(0, 0, jumpMultiplierPerYear, kink_);
        poke();
    }
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) public view returns (uint) {
        uint protocolRate = super.getSupplyRate(cash, borrows, reserves, reserveFactorMantissa);

        uint underlying = cash.add(borrows).sub(reserves);
        if (underlying == 0) {
            return protocolRate;
        } else {
            uint cashRate = cash.mul(dsrPerBlock()).div(underlying);
            return cashRate.add(protocolRate);
        }
    }
    function dsrPerBlock() public view returns (uint) {
        return pot
            .dsr().sub(1e27)  // scaled 1e27 aka RAY, and includes an extra "ONE" before subraction
            .div(1e9) // descale to 1e18
            .mul(15); // 15 seconds per block
    }
    function poke() public {
        (uint duty, ) = jug.ilks("ETH-A");
        uint stabilityFeePerBlock = duty.add(jug.base()).sub(1e27).mul(1e18).div(1e27).mul(15);

        // We ensure the minimum borrow rate >= DSR / (1 - reserve factor)
        baseRatePerBlock = dsrPerBlock().mul(1e18).div(assumedOneMinusReserveFactorMantissa);

        // The roof borrow rate is max(base rate, stability fee) + gap, from which we derive the slope
        if (baseRatePerBlock < stabilityFeePerBlock) {
            multiplierPerBlock = stabilityFeePerBlock.sub(baseRatePerBlock).add(gapPerBlock).mul(1e18).div(kink);
        } else {
            multiplierPerBlock = gapPerBlock.mul(1e18).div(kink);
        }

        emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink);
    }
}


/*** Maker Interfaces ***/

contract PotLike {
    function chi() external view returns (uint);
    function dsr() external view returns (uint);
    function rho() external view returns (uint);
    function pie(address) external view returns (uint);
    function drip() external returns (uint);
    function join(uint) external;
    function exit(uint) external;
}

contract JugLike {
    // --- Data ---
    struct Ilk {
        uint256 duty;
        uint256  rho;
    }
   mapping (bytes32 => Ilk) public ilks;
   uint256 public base;
}