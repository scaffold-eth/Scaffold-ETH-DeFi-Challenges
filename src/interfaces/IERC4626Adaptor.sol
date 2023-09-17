// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { SingleSwap, JoinPoolRequest, SwapKind, FundManagement, ExitPoolRequest } from "src/interfaces/external/Balancer/IVault.sol";
import { ILiquidityGaugev3Custom } from "src/interfaces/external/Balancer/ILiquidityGaugev3Custom.sol";

/**
 * @title IERC4626Adaptor.sol
 * @author crispymangoes, 0xEinCodes
 * @notice An interface outlining the concepts and some functions needed for current-day ERC4626s to integrate into protocols using protocol-bespoke functions. 
 * @dev The intent is to showcase how standards like ERC4626 push open-source collaboration, and continuously rely on it. The adaptors that Sommelier creates can be simplified to offer ERC4626 agnostic adaptors, where minimal extra auditing is needed. These effectively act as APIs for respective protocols and other ERC4626 projects.
 * @dev Example of implementation used in Sommelier protocol found here: https://github.com/PeggyJV/cellar-contracts/blob/main/src/modules/adaptors/Balancer/BalancerPoolAdaptor.sol && tests here: https://github.com/PeggyJV/cellar-contracts/blob/main/test/testAdaptors/BalancerPoolAdaptor.t.sol
 * NOTE: A full yield aggregator protocol or any others using ERC 4626 vaults will likely need to keep track of pricing of BPTs wrt a base asset. This aspect is left up to the respective protocol to design and implement. Pricing examples using the Sommelier protocol pricing architecture are outlined to illustrate pricing the various types of BPTs.
 * NOTE: This adaptor and pricing derivatives focus on stablepool BPTs
 */
interface IERC4626Adaptor {

    /**
     * Basic Steps for creating an IERC4626Adaptor
     * 1. Think about what the ERC4626 Vaults you're working on want to do with the external protocol.
     * 2. Outline "Strategist Functions," aka functions that enact external function calls to the external protocol with the Vault funds / context.
     * 3. Implement these "Strategist Functions."
     * 4. Implement any 'hooks' from your respective protocol. Ex.) Sommelier Protocol Architecture allows having their ERC4626 Vaults to have a "holdingPosition" where Vault funds can be automatically transferred using a Strategist Function with a respective ERC4626 Adaptor.
     * 5. Implement any 'pricing' mechanisms required to have the ERC4626 Adaptor compatible with the Vault architecture you are working with.
     */

    /// Strategist Functions - Where external function calls occur to the respective underlying protocol. ex.) Balancer Protocol
    // NOTE: these function calls can be confusing since there requires a comprehensive knowledge of the underlying protocol's codebase. This is another reason to share resources amongst DeFi so fast-paced innovation is prioritized vs competition.

    /// Helper Functions - This is where common helpers are kept. These can be abstracted to an abstract library though.

    // examples incl. maxAvailable() etc.abi
    
}
