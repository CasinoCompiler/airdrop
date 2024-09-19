// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title   Merkle Airdrop
 * @author  CC
 * @notice
 * @dev
 */

/**
 * Imports
 */
// @Order Imports, Interfaces, Libraries, Contracts
import {IMerkleAirdrop} from "./IMerkleAirdrop.sol";
import {MerkleProof} from "@oz/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@oz/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop is IMerkleAirdrop {
    /**
     * Errors
     */
    error MerkleAirdrop__ProofDenied();
    error MerkleAirdrop__AlreadyClaimed();

    /**
     * Type Declarations
     */
    using SafeERC20 for IERC20;

    /**
     * State Variables
     */
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    address[] private s_claimers;
    mapping(address => bool) private s_addressToHasClaimed;

    /**
     * Constructor
     */
    constructor(bytes32 merkleProof, IERC20 token) {
        i_merkleRoot = merkleProof;
        i_airdropToken = token;
    }

    /**
     * Modifiers
     */

    /**
     * Functions
     */
    // @Order recieve, fallback, external, public, internal, private
    function claim(address claimAddress, uint256 amountToClaim, bytes32[] calldata merkleProof) external {
        if (s_addressToHasClaimed[claimAddress]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(claimAddress, amountToClaim))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__ProofDenied();
        }
        s_claimers.push(claimAddress);
        s_addressToHasClaimed[claimAddress] = true;
        i_airdropToken.safeTransfer(claimAddress, amountToClaim);
        emit Claimed(claimAddress, amountToClaim);
    }

    /**
     * Getter Functions
     */
    function getMerkelRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (address) {
        return address(i_airdropToken);
    }

    function getDecimals() public pure returns(uint256) {
        return 18;
    }

    function getClaimEligibility(address _address) public view returns (bool) {}

    function getClaimStatus(address _address) public view returns (bool) {
        return s_addressToHasClaimed[_address];
    }
}
