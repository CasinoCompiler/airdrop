// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "@forge/src/Test.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";

contract DeployMerkleAirdropTest is Test {
    DeployMerkleAirdrop deployMerkleAirdrop;
    ERC20 token;
    MerkleAirdrop airdrop;

    function setUp() public {
        deployMerkleAirdrop = new DeployMerkleAirdrop();
        (token, airdrop) = deployMerkleAirdrop.run();
    }

    /*//////////////////////////////////////////////////////////////
                                  INIT
    //////////////////////////////////////////////////////////////*/
    function test_ERC20TokenDeployed() public view {
        address log = address(token);
        console.log("Token address:", log);
        assert(address(token) != address(0));
    }

    function test_MerkleAirdropDeployed() public view {
        address log = address(airdrop);
        console.log("Airdrop token address:", log);
        assert(address(airdrop) != address(0));
    }

    function test_TokensSentToAirdropContract() public view {
        uint256 balance = ERC20(address(token)).balanceOf(address(airdrop));
        uint256 expectedBalance = 1e21;

        assertEq(expectedBalance, balance);
    }

    /**
     * @dev implement programmatic way to test merkle root.
     */
}
