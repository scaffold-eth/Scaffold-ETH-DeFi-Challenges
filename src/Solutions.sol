// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.12;
pragma experimental ABIEncoderV2;

// These are the core Yearn libraries
import { BaseStrategy, StrategyParams } from "@yearnvaults/contracts/BaseStrategy.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./interfaces/Compound/ICToken.sol";

/// @title BasicYearnCompoundDAIStrategy
/// @notice First strategy tutorial for Scaffold-ETH inspired by @charlesndalton's session in September: https://www.youtube.com/watch?v=z48R7dhAGP4&ab_channel=ETHGlobal && was built off of the foundrymix by @storming0x
/// @author @cDalton && @steve0xp
contract Strategy is BaseStrategy {
  using SafeERC20 for IERC20;
  using Address for address;

  ICToken internal constant cDAI =
    ICToken(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);

  constructor(address _vault) BaseStrategy(_vault) {
    want.approve(address(cDAI), type(uint256).max);
  }

  /// @notice names the strategy
  /// @return name of the strategy
  /// @dev defined in implementation, called by constructor 
  function name() external view override returns (string memory) {
    return "StrategyCompoundDAI";
  }

  /// @notice calculates an estimated total of wantToken within strategy contract && deployed in strategy itself
  /// @return estimated total wantToken (including converted assets)
  function estimatedTotalAssets() public view override returns (uint256) {
    return
      want.balanceOf(address(this)) +
      (cDAI.balanceOf(address(this)) * cDAI.exchangeRateStored()) /
      1e18;
  }


  /// @notice prepares return and reporting the accounting losses and gains from the last time harvest() has been called. 
  /// @param _debtOutstanding amount of wantToken vault wants at a specific function call
  /// @dev Part of Harvest "flow" - bot calls harvest() it calls this function && adjustPosition(). You're preparing the return of the DAI, liquidiating anything you can to get that amount back to the vault.
  /// @return _profit amount since last harvest, if any
  /// @return _loss amount since last harvest, if any
  /// @return _debtPayment payable during this harvest() call
  function prepareReturn(uint256 _debtOutstanding)
    internal
    override
    returns (
      uint256 _profit,
      uint256 _loss,
      uint256 _debtPayment
    )
  {
    uint256 _totalAssets = estimatedTotalAssets();
    uint256 _totalDebt = vault.strategies(address(this)).totalDebt;

    if (_totalAssets >= _totalDebt) {
      _profit = _totalAssets - _totalDebt;
      _loss = 0;
    } else {
      _profit = 0;
      _loss = _totalDebt - _totalAssets;
    }

    withdrawSome(_debtOutstanding + _profit); // _profit needs to be liquid in wantToken, so `withdrawSome()` takes care of that

    uint256 _liquidWant = want.balanceOf(address(this));

    // enough to pay profit (partial or full) only
    if (_liquidWant <= _profit) {
      _profit = _liquidWant;
      _debtPayment = 0;
      // enough to pay for all profit and _debtOutstanding (partial or full)
    }
  }

  /// @notice invests excess wantToken into the strategy
  /// @dev Part of harvest "flow" - bot calls harvest(), it calls this function && prepareReturn()
  function adjustPosition(uint256 _debtOutstanding) internal override {
    uint256 _daiBal = want.balanceOf(address(this));

    if (_daiBal > _debtOutstanding) {
      uint256 _excessDai = _daiBal - _debtOutstanding;
      // cToken function mint() gives back a uint256 == 0 if it is successful.
      uint256 _status = cDAI.mint(_excessDai);
      assert(_status == 0);
    }
  }

  /// @notice exits strategy protocol contracts and extracts wantToken
  /// @param _amountNeeded total wantToken requested
  function withdrawSome(uint256 _amountNeeded) internal {
    uint256 _cDaiToBurn = Math.min(
      (_amountNeeded * 1e18) / cDAI.exchangeRateStored(),
      cDAI.balanceOf(address(this))
    );
    uint256 _status = cDAI.redeem(_cDaiToBurn);
    assert(_status == 0);
  }

  /// @notice part of vault.withdraw() flow where strategy liquidates as much as possible, if not enough then declare losses.
  /// @dev user calls withdraws from vault, calling withdraw on the strategy which then calls this function
  /// @param _amountNeeded total wantToken required from liquidating active strategy positions
  /// @return _liquidatedAmount of wantToken during this call
  /// @return _loss of wantToken during this call
  function liquidatePosition(uint256 _amountNeeded)
    internal
    override
    returns (uint256 _liquidatedAmount, uint256 _loss)
  {
    uint256 _daiBal = want.balanceOf(address(this));

    if (_daiBal >= _amountNeeded) {
      return (_amountNeeded, 0);
    }

    withdrawSome(_amountNeeded);

    _daiBal = want.balanceOf(address(this));
    if (_amountNeeded > _daiBal) {
      _liquidatedAmount = _daiBal;
      _loss = _amountNeeded - _daiBal;
    } else {
      _liquidatedAmount = _amountNeeded;
    }
  }

  /// @notice liquidate all strategy positions to obtain wantToken
  /// @return total wantToken balance after all positions liquidated
  function liquidateAllPositions() internal override returns (uint256) {
    uint256 _status = cDAI.redeem(cDAI.balanceOf(address(this)));
    assert(_status == 0);
    return want.balanceOf(address(this));
  }

  /// @notice transfer any non-want tokens to a new strategy, if you change the strategy code and deploy a new one.
  /// @dev can override `tendTrigger` and `harvestTrigger` if necessary
  function prepareMigration(address _newStrategy) internal override {
    cDAI.transfer(_newStrategy, cDAI.balanceOf(address(this)));
  }

  // *********** IGNORE BELOW FOR TUTORIAL *********** //

  // Override this to add all tokens/tokenized positions this contract manages
  // on a *persistent* basis (e.g. not just for swapping back to want ephemerally)
  // NOTE: Do *not* include `want`, already included in `sweep` below
  //
  // Example:
  //
  //    function protectedTokens() internal override view returns (address[] memory) {
  //      address[] memory protected = new address[](3);
  //      protected[0] = tokenA;
  //      protected[1] = tokenB;
  //      protected[2] = tokenC;
  //      return protected;
  //    }
  function protectedTokens()
    internal
    view
    override
    returns (address[] memory)
  // solhint-disable-next-line no-empty-blocks
  {

  }

  /**
   * @notice
   *  Provide an accurate conversion from `_amtInWei` (denominated in wei)
   *  to `want` (using the native decimal characteristics of `want`).
   * @dev
   *  Care must be taken when working with decimals to assure that the conversion
   *  is compatible. As an example:
   *
   *      given 1e17 wei (0.1 ETH) as input, and want is USDC (6 decimals),
   *      with USDC/ETH = 1800, this should give back 1800000000 (180 USDC)
   *
   * @param _amtInWei The amount (in wei/1e-18 ETH) to convert to `want`
   * @return The amount in `want` of `_amtInEth` converted to `want`
   **/
  function ethToWant(uint256 _amtInWei)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _amtInWei;
  }
}
