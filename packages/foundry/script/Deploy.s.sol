//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeployHelpers.s.sol";
import {AuraERC4626Adaptor} from "../contracts/Solutions/AuraERC4626Adaptor.sol";
import {ERC4626Adaptor} from "../contracts/Solutions/ERC4626Adaptor.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);
        ERC4626Adaptor erc4626Adapator = new ERC4626Adaptor();
        console.logString(
            string.concat(
                "auraAdaptor contract deployed at: ",
                vm.toString(address(erc4626Adapator))
            )
        );

        AuraERC4626Adaptor auraAdaptor = new AuraERC4626Adaptor();
        console.logString(
            string.concat(
                "AuraERC4626Adaptor contract deployed at: ",
                vm.toString(address(auraAdaptor))
            )
        );
        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
