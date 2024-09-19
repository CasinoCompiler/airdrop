// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {ERC20Maker} from "../src/ERC20Maker.sol";
import {Ownable} from "@oz/contracts/access/Ownable.sol";
import {Script} from "@forge/src/Script.sol";

contract DeployERC20 is Script {
    ERC20Maker token;
    string tokenName = "Bagel Token";
    string tokenSymbol = "BT";

    address public deployerAddress = address(this);
    address public owner;

    uint256 public INITIAL_MINT_AMOUNT = 1_000_000 * 1e18;

    function run() public returns (ERC20) {
        vm.startBroadcast();
        token = new ERC20Maker(tokenName, tokenSymbol);
        owner = Ownable(address(token)).owner();
        ERC20Maker(address(token)).mint(owner, INITIAL_MINT_AMOUNT);
        vm.stopBroadcast();
        return token;
    }
}
