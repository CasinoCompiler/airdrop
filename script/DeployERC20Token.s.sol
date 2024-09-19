// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {ERC20Maker} from "../src/ERC20Maker.sol";
import {Script} from "@forge/src/Script.sol";

contract DeployERC20 is Script {
    ERC20Maker erc20Token;
    string tokenName = "Bagel Token";
    string tokenSymbol = "BT";

    function run() public returns (ERC20) {
        vm.startBroadcast();
        erc20Token = new ERC20Maker(tokenName, tokenSymbol);
        vm.stopBroadcast();
        return erc20Token;
    }
}
