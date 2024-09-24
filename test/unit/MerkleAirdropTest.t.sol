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
    address user;
    uint256 userPrivKey;
    address GAS_PAYER;

    uint8 v;
    bytes32 r;
    bytes32 s;

    uint256 CLAIM_AMOUNT;
    bytes32[] public PROOF;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        deployMerkleAirdrop = new DeployMerkleAirdrop();
        (bagel, airdrop) = deployMerkleAirdrop.run();
        CLAIM_AMOUNT = deployMerkleAirdrop.CLAIM_AMOUNT();
        OWNER = Ownable(address(bagel)).owner();
        GAS_PAYER = makeAddr("gasPayer");

        // Create users and private keys
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function _generateSignature(address _user, uint256 _privateKey) internal {
        bytes32 message = airdrop.getMessage(_user, CLAIM_AMOUNT);
        (v, r, s) = vm.sign(_privateKey, message);
    }

    /*//////////////////////////////////////////////////////////////
                                  INIT
    //////////////////////////////////////////////////////////////*/
    function test_UserAddress() public view {
        address derivedAddress = vm.addr(userPrivKey);
        assert(derivedAddress == 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D);
    }

    /*//////////////////////////////////////////////////////////////
                                 CLAIM
    //////////////////////////////////////////////////////////////*/

    modifier getSignature(address _user, uint256 _privateKey) {
        _generateSignature(_user, _privateKey);
        _;
    }

    modifier getUser1Sig() {
        _generateSignature(user, userPrivKey);
        _;
    }

    function test_UserCanClaim() public getUser1Sig {
        uint256 startingBalance = bagel.balanceOf(user);

        bytes32 proofOne = 0xf952d6ed6654b0ecf9e6365c4ef2f833061953b1f63fdc6e3b38535b18e900fe;
        bytes32 proofTwo = 0x791ab65982405a68894590b771f7170f1c5560bc580d6c817314aa43cbb12960;
        PROOF = [proofOne, proofTwo];

        vm.prank(GAS_PAYER);
        airdrop.claim(user, CLAIM_AMOUNT, PROOF, v, r, s);

        uint256 endingBalance = bagel.balanceOf(user);

        assert(startingBalance != endingBalance);
        assertEq(bagel.balanceOf(user), CLAIM_AMOUNT);
    }

    function test_UserCantClaimAgain() public getUser1Sig {
        bytes32 proofOne = 0xf952d6ed6654b0ecf9e6365c4ef2f833061953b1f63fdc6e3b38535b18e900fe;
        bytes32 proofTwo = 0x791ab65982405a68894590b771f7170f1c5560bc580d6c817314aa43cbb12960;
        PROOF = [proofOne, proofTwo];

        vm.prank(user);
        airdrop.claim(user, CLAIM_AMOUNT, PROOF, v, r, s);

        vm.prank(user);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        airdrop.claim(user, CLAIM_AMOUNT, PROOF, v, r, s);
    }

    function test_UserCantClaimWithIncorrectMerkleProof() public getUser1Sig {
        bytes32 proofOne = 0xf952d6ed6654b0ecf9e6365c4ef2f833061953b1f63fdc6e3b38535b18e900fe;
        bytes32 proofTwo = 0xbeb22b1203940a25797bfbb71c5f4860dd1d677d950bf72e6c1913bb42544431;
        PROOF = [proofOne, proofTwo];

        vm.prank(user);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__ProofDenied.selector);
        airdrop.claim(user, CLAIM_AMOUNT, PROOF, v, r, s);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/
}
