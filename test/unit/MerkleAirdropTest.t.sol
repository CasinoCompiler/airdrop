// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "@forge/src/Test.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@oz/contracts/access/Ownable.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {GenerateInput} from "../../script/GenerateInput.s.sol";

contract MerkleAirdropTest is Test {
    DeployMerkleAirdrop deployMerkleAirdrop;
    ERC20 public bagel;
    MerkleAirdrop public airdrop;
    GenerateInput generateInput;

    address OWNER;
    address USER_1 = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;
    address USER_2 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address USER_3 = 0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd;
    address USER_4 = 0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D;

    uint256 CLAIM_AMOUNT;
    uint256 WHITELIST_COUNT = 4;
    uint256 AMOUNT_TO_SEND_TO_AIRDROP_ADDRESS;
    bytes32[] public PROOF;

    function setUp() public {
        deployMerkleAirdrop = new DeployMerkleAirdrop();
        (bagel, airdrop) = deployMerkleAirdrop.run();
        generateInput = new GenerateInput();
        CLAIM_AMOUNT = generateInput.AMOUNT();
        AMOUNT_TO_SEND_TO_AIRDROP_ADDRESS = CLAIM_AMOUNT * WHITELIST_COUNT;
        OWNER = Ownable(address(bagel)).owner();

        // Send tokens to airdrop address for claim
        vm.prank(OWNER);
        ERC20(address(bagel)).transfer(address(airdrop), AMOUNT_TO_SEND_TO_AIRDROP_ADDRESS);
    }

    /*//////////////////////////////////////////////////////////////
                                  INIT
    //////////////////////////////////////////////////////////////*/
    function test_TokensSentToAirdropContract() public view {
        uint256 balance = ERC20(address(bagel)).balanceOf(address(airdrop));
        uint256 expectedBalance = 1e21;

        assertEq(expectedBalance, balance);
    }

    /*//////////////////////////////////////////////////////////////
                                 CLAIM
    //////////////////////////////////////////////////////////////*/
    function test_UserCanClaim() public {
        uint256 startingBalance = bagel.balanceOf(USER_1);

        bytes32 proofOne = 0xf952d6ed6654b0ecf9e6365c4ef2f833061953b1f63fdc6e3b38535b18e900fe;
        bytes32 proofTwo = 0x791ab65982405a68894590b771f7170f1c5560bc580d6c817314aa43cbb12960;
        PROOF = [proofOne, proofTwo];

        vm.prank(USER_1);
        airdrop.claim(USER_1, CLAIM_AMOUNT, PROOF);

        uint256 endingBalance = bagel.balanceOf(USER_1);

        assert(startingBalance != endingBalance);
        assertEq(bagel.balanceOf(USER_1), CLAIM_AMOUNT);
    }

    function test_UserCantClaimAgain() public {
        bytes32 proofOne = 0xf952d6ed6654b0ecf9e6365c4ef2f833061953b1f63fdc6e3b38535b18e900fe;
        bytes32 proofTwo = 0x791ab65982405a68894590b771f7170f1c5560bc580d6c817314aa43cbb12960;
        PROOF = [proofOne, proofTwo];

        vm.prank(USER_1);
        airdrop.claim(USER_1, CLAIM_AMOUNT, PROOF);

        vm.prank(USER_1);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        airdrop.claim(USER_1, CLAIM_AMOUNT, PROOF);
    }

    function test_UserCantClaimWithIncorrectMerkleProof() public {
        bytes32 proofOne = 0xf952d6ed6654b0ecf9e6365c4ef2f833061953b1f63fdc6e3b38535b18e900fe;
        bytes32 proofTwo = 0xbeb22b1203940a25797bfbb71c5f4860dd1d677d950bf72e6c1913bb42544431;
        PROOF = [proofOne, proofTwo];

        vm.prank(USER_1);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__ProofDenied.selector);
        airdrop.claim(USER_1, CLAIM_AMOUNT, PROOF);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/
}
