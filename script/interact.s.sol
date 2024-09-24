// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "@forge/src/Script.sol";
import {DevOpsTools} from "@devops/src/DevOpsTools.sol";
import {IMerkleAirdrop} from "../src/IMerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropInteractions is Script{
error __ClaimAirdropScript__InvalidSignatureLength();

    DeployMerkleAirdrop deployMerkleAirdrop;

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIM_AMOUNT;
    bytes32 proof1 = 0x59f0e16ebc95ca9d63431fc3051d567963dbf9ac7ef3eb5cbdf3a1b66a327e2c;
    bytes32 proof2 = 0x791ab65982405a68894590b771f7170f1c5560bc580d6c817314aa43cbb12960;
    bytes32[] PROOF = [proof1, proof2];
    uint8 v;
    bytes32 r;
    bytes32 s;
    bytes private SIGNATURE = hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";

    function run() external {
        deployMerkleAirdrop = new DeployMerkleAirdrop();
        CLAIM_AMOUNT = deployMerkleAirdrop.CLAIM_AMOUNT();
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentDeployment);
    }

    function claimAirdrop(address airdropContractAddress) public {
        vm.startBroadcast();
        (v, r, s) = splitSignature(SIGNATURE);
        IMerkleAirdrop(airdropContractAddress).claim(
            CLAIMING_ADDRESS,
            CLAIM_AMOUNT,
            PROOF,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 _v, bytes32 _r, bytes32 _s) {
        if (sig.length != 65) {
            revert __ClaimAirdropScript__InvalidSignatureLength();
        }   
        assembly {
            _r := mload(add(sig, 32))
            _s := mload(add(sig, 64))
            _v := byte(0, mload(add(sig, 96)))
        }
        return (_v, _r, _s);
    }

}