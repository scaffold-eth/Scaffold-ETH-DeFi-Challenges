// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import { BaseAdaptor, ERC20, SafeTransferLib, Cellar } from "@cellar-contracts/src/modules/adaptors/BaseAdaptor.sol";
import { ERC4626 } from "@solmate/mixins/ERC4626.sol";

/**
 * @title IERC4626Adaptor.sol
 * @author crispymangoes & 0xEinCodes originally. Edited to be a tutorial challenge by steve0xp
 * @notice A challenge outlining the concepts and some functions needed for current-day ERC4626s to integrate into protocols using protocol-bespoke functions. 
 * @dev The intent is to showcase how standards like ERC4626 push open-source collaboration, and continuously rely on it. The adaptors that Sommelier creates can be simplified to offer ERC4626 agnostic adaptors, where minimal extra auditing is needed. These effectively act as APIs for respective protocols and other ERC4626 projects.
 * @dev This Challenge showcases the steps for creating an adaptor. 
 * @dev Example of implementation used in Sommelier protocol found here: https://github.com/PeggyJV/cellar-contracts/pull/141
 * NOTE: A full yield aggregator protocol or any others using ERC 4626 vaults will likely need to keep track of pricing of BPTs wrt a base asset. This aspect is left up to the respective protocol to design and implement. Pricing examples using the Sommelier protocol pricing architecture are outlined to illustrate pricing the various types of BPTs.
 * NOTE: This adaptor and pricing derivatives focus on stablepool BPTs
 */
contract ERC4626Adaptor is BaseAdaptor {
    using SafeTransferLib for ERC20;

    //==================== Adaptor Data Specification ====================
    // adaptorData = abi.encode(ERC4626 erc4626Vault)
    // Where:
    // `erc4626Vault` is the underling ERC4626 this adaptor is working with
    //================= Configuration Data Specification =================
    // configurationData = abi.encode(bool isLiquid)
    // Where:
    // `isLiquid` dictates whether the position is liquid or not
    // If true:
    //      position can support use withdraws
    // else:
    //      position can not support user withdraws
    //
    //====================================================================

    /**
     * @notice Strategist attempted to interact with a erc4626Vault with no position setup for it.
     */
    error ERC4626Adaptor__CellarPositionNotUsed(address erc4626Vault);

    //============================================ Global Functions ===========================================
    /**
     * @notice Encoded identifier unique to this adaptor for a shared registry.
     * @return encoded string identifying adaptor w/ version number
     */
    function identifier() public pure virtual override returns (bytes32) {
        // TODO: implementation code returning encoding string identifying adaptor
    }

    //============================================ Sommelier Cellar Base Functions Implementations  ===========================================
    /**
     * @notice Cellar must approve ERC4626 position to spend its assets, then deposit into the ERC4626 position.
     * @param assets the amount of assets to deposit into the ERC4626 position
     * @param adaptorData adaptor data containing the abi encoded ERC4626
     * @dev configurationData is NOT used
     */
    function deposit(uint256 assets, bytes memory adaptorData, bytes memory) public virtual override {

        // TODO: decode adaptorData to get the respective erc4626Vault
        // TODO: verify that the ERC4626PositionIsUsed in Sommelier Architecture
        // TODO: deposit assets to `erc4626Vault` from msg caller - NOTE: Sommelier protocol carries out delegate calls to this function.
        // TODO: revoke any external approval for the erc4626Vault to handle the msg caller's assets.

    }

    /**
     * @notice Cellar needs to call withdraw on ERC4626 position, but must first check if position is liquid or not.
     * @dev Important to verify that external receivers are allowed if receiver is not Cellar address.
     * @param assets the amount of assets to withdraw from the ERC4626 position
     * @param receiver address to send assets to'
     * @param adaptorData data needed to withdraw from the ERC4626 position
     * @param configurationData abi encoded bool indicating whether the position is liquid or not
     */
    function withdraw(
        uint256 assets,
        address receiver,
        bytes memory adaptorData,
        bytes memory configurationData
    ) public virtual override {

        // TODO: decode configurationData for bool var indicating if position is liquid or not. If it is not liquid, what do you think should happen? Hint: in this scenario, the calling cellar would be wanting to withdraw funds out of any position it can. It would go through the most liquid positions first right? See Cellar code for more context. Thus, it would revert if the configData reported a falsey for whether the position was liquid or not.
        // TODO: run external receiver check.
        // TODO: withdraw assets from `cellar` --> decode the ERC4626 erc4626Vault from adaptorData. Verify the ERC4626 is used (see `_verifyERC4626PositionIsUsed()` helper)
        // TODO: withdraw the actual assets to calling cellar. NOTE: Sommelier protocol carries out delegate calls to this function.

    }

    /**
     * @notice Cellar needs to call `maxWithdraw` to see if its assets are locked.
     * @dev See Cellar.sol within cellar-contracts repo from PeggyJV && cmd + f `withdrawableFrom()` to better understand how it works. Essentially there are checks throughout the `withdraw` tx flow where Cellar positions are checked for the type of position they are. If they are not debt, they can be withdrawn for example typically.
     */
    function withdrawableFrom(
        bytes memory adaptorData,
        bytes memory configurationData
    ) public view virtual override returns (uint256) {

        // TODO: decode configurationData and get bool var indicating whether position isLiquid or not. If it is illiquid, revert.
        // TODO: in accordance to erc4626 standard, obtain the max withdrawable amount of assets for the msg sender

    }

    /**
     * @notice Uses ERC4626 `previewRedeem` to determine Cellars balance in ERC4626 position.
     * @dev The Sommelier architecture requires that the function `balanceOf()` returns an appropriate, true, value of assets wihtin the respective Cellar position. This varies based on what external protocol the adaptor is allowing the Cellar to hold a position with said protocol. In the case of general ERC4626 vaults, Sommelier typically uses the `previewRedeem()` function within the erc4626 standard to evaluate the total balance of assets within an erc4626 vault for a user. 
     */
    function balanceOf(bytes memory adaptorData) public view virtual override returns (uint256) {
        
        // TODO: decode adaptorData to get ERC4626 erc4626Vault that the function will carry out an external function call, `previewRedeem()` to get the balance for the msg.sender

    }

    /**
     * @notice Returns the asset the ERC4626 position uses.
     */
    function assetOf(bytes memory adaptorData) public view virtual override returns (ERC20) {
        // TODO: `assetOf()` needs to decode param `bytes memory adaptorData` and return the underlying ERC20 within the ERC4626 Vault that the caller is depositing into said vault.
    }

    /**
     * @notice This adaptor returns collateral, and not debt.
     */
    function isDebt() public pure virtual override returns (bool) {
        return false;
    }

    //============================================ Strategist Functions ===========================================
    /**
     * @notice Allows strategists to deposit into ERC4626 positions.
     * @dev Uses `_maxAvailable` helper function, see BaseAdaptor.sol
     * @param erc4626Vault the ERC4626 to deposit `assets` into
     * @param assets the amount of assets to deposit into `cellar`
     */
    function depositToVault(ERC4626 erc4626Vault, uint256 assets) public {

        // TODO: write implementation

    }

    /**
     * @notice Allows strategists to withdraw from ERC4626 positions.
     * @param erc4626Vault the ERC4626 to withdraw `assets` from
     * @param assets the amount of assets to withdraw from `cellar`
     */
    function withdrawFromVault(ERC4626 erc4626Vault, uint256 assets) public {
       
        // TODO: write implementation

    }

    //============================================ Helper Functions ===========================================

    /**
     * @notice Reverts if a given `erc4626Vault` is not set up as a position in the calling Cellar.
     * @dev This function is only used in a delegate call context, hence why address(this) is used
     *      to get the calling Cellar.
     */
    function _verifyERC4626PositionIsUsed(address erc4626Vault) internal view {
        
        // Check that erc4626Vault position is setup to be used in the calling cellar.
        // TODO: write implementation

    }
}
