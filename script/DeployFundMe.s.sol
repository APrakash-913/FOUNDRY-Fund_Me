// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // ⚠️⚠️ Deploying "HelperConfig" before "startBroadcast" becoz I dont want to 🚀spend GAS🚀 in deploying the "HelperConfig" on a Chain.
        // ⚠️ before "startBroadcast" -> Not a REAL Txn.
        HelperConfig helperConfig = new HelperConfig();

        // ⚠️ After "startBroadcast" -> REAL Txn.
        vm.startBroadcast();
        FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMe;
    }
}
