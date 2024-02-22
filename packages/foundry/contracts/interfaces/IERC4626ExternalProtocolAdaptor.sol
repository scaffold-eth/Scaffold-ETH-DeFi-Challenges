// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;


/**
 * @title IERC4626ExternalProtocolAdaptor.sol
 * @author crispymangoes, 0xEinCodes. Edited / Brought in to be a tutorial challenge by steve0xp
 * @notice An interface outlining the concepts and some functions needed for current-day ERC4626s to integrate into protocols using protocol-bespoke functions. For the challenge, simply read over the comments here to understand how we will break the challenge up.
 * @dev The intent is to showcase an example contract on integrating btw ERC4626s and external protocols. This is done in a series of steps. This also shows how standards like ERC4626 push open-source collaboration, and continuously rely on it. The adaptors that Sommelier creates can be simplified to offer ERC4626 agnostic adaptors, where minimal extra auditing is needed. These effectively act as APIs for respective protocols and other ERC4626 projects.
 * @dev Example of implementation used in Sommelier protocol found here: https://github.com/PeggyJV/cellar-contracts/pull/141
 * NOTE: A full yield aggregator protocol or any others using ERC 4626 vaults will likely need to keep track of pricing of BPTs wrt a base asset. This aspect is left up to the respective protocol to design and implement. Pricing examples using the Sommelier protocol pricing architecture are outlined to illustrate pricing the various types of BPTs.
 * NOTE: This adaptor and pricing derivatives focus on stablepool BPTs
 */
contract IERC4626ExternalProtocolAdaptor  {

    //============================================ BASIC STEPS FOR CREATING IERC4626ADAPTOR  ===========================================

    /**
     * 1. Think about what the ERC4626 Vaults you're working on want to do with the external protocol.
     * 2. Outline "Strategist Functions," aka functions that enact external function calls to the external protocol with the Vault funds / context.
     * 3. Implement these "Strategist Functions."
     * 4. Implement any 'hooks' from your respective protocol. Ex.) Sommelier Protocol Architecture allows having their ERC4626 Vaults to have a "holdingPosition" where Vault funds can be automatically transferred using a Strategist Function with a respective ERC4626 Adaptor.
     * 5. Implement any 'pricing' mechanisms required to have the ERC4626 Adaptor compatible with the Vault architecture you are working with. [FOR THE TUTORIAL, THIS IS NOT NECESSARY TO UNDERSTAND THOROUGHLY]
     */

    //============================================ Strategist Functions ===========================================

    /// Strategist Functions - Where external function calls occur to the respective underlying protocol. ex.) Aura protocol where we want to be able to enter and exit auraPools, and claim any rewards from staking BPT.
    // NOTE: these function calls can be confusing since there requires a comprehensive knowledge of the underlying protocol's codebase. This is another reason having more people know how to create integration contracts between ERC4626 vaults and protocols is valuable. 

    //============================================ Helper Functions ===========================================

    /// Helper Functions - This is where common helpers are kept. These can be abstracted to an abstract library though.

    // examples incl. maxAvailable() etc.abi

    
}
