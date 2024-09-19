// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "@forge/src/Script.sol";
import {console} from "@forge/src/Test.sol";
import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {DeployERC20} from "./DeployERC20Token.s.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

import {GenerateInput} from "./GenerateInput.s.sol";
import {MerkleScript} from "@murky/script/Merkle.s.sol";

contract DeployMerkleAirdrop is Script {
    // MERKLE ROOT found in output.json
    bytes32 public MERKLE_ROOT = 0x5ac459a81bcaa56a5759053ab8f6bf00f07c221dad9c86e094d605e8bd074603;

    DeployERC20 public deployERC20;
    ERC20 public bagel;

    GenerateInput public generateInput;
    MerkleScript public generateMerkle;

    function run() public returns (ERC20, MerkleAirdrop) {
        // Deploy ERC20 token
        deployERC20 = new DeployERC20();
        bagel = deployERC20.run();

        // Generate Merkle Proof
        generateInput = new GenerateInput();
        generateInput.run();
        generateMerkle = new MerkleScript();
        generateMerkle.run();

        // Deploy Merkle Airdrop
        vm.startBroadcast();
        MerkleAirdrop airdrop = new MerkleAirdrop(MERKLE_ROOT, bagel);
        vm.stopBroadcast();

        return (bagel, airdrop);
    }
}
