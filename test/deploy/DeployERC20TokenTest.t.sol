// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "@forge/src/Test.sol";
import {DeployERC20} from "../../script/DeployMerkleAirdrop.s.sol";
import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {ERC20Maker} from "../../src/ERC20Maker.sol";
import {Ownable} from "@oz/contracts/access/Ownable.sol";

contract DeployERC20Test is Test {
    DeployERC20 deployERC20;
    ERC20 token;

    address public owner;

    function setUp() public {
        deployERC20 = new DeployERC20();
        token = deployERC20.run();
        owner = Ownable(address(token)).owner();
    }

    /*//////////////////////////////////////////////////////////////
                                  INIT
    //////////////////////////////////////////////////////////////*/
    function test_DeployerAddress() public view {
        address addressThroughAssignment = deployERC20.owner();

        assertEq(owner, addressThroughAssignment);
    }

    function test_InitialSupply() public view {
        uint256 expectedInitialMint = 1_000_000;
        uint256 actualBalance = ERC20(token).balanceOf(owner);

        assertEq(expectedInitialMint, actualBalance);
    }
}
