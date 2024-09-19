// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {DeployERC20} from "./DeployERC20Token.s.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Script} from "@forge/src/Script.sol";

contract DeployMerkleAirdrop is Script {

    bytes32 merkleRoot;

    DeployERC20 deployERC20;

    function run() public returns (ERC20, MerkleAirdrop) {
        ERC20 bagel = deployERC20.run();

        vm.startBroadcast();
        MerkleAirdrop airdrop = new MerkleAirdrop(merkleRoot, bagel);
        vm.stopBroadcast();

        return(bagel, airdrop);
    }
}
