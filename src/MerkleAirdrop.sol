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
import {EIP712} from "@oz/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@oz/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is IMerkleAirdrop, EIP712 {
    /**
     * Errors
     */
    error MerkleAirdrop__ProofDenied();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__SignatureDenied();

    /**
     * Type Declarations
     */
    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /**
     * State Variables
     */
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    mapping(address => bool) private s_addressToHasClaimed;

    /**
     * Constructor
     */
    constructor(bytes32 merkleProof, IERC20 token) EIP712("MerkleAirdrop", "0.1.0") {
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
    function claim(
        address claimAddress,
        uint256 amountToClaim,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Check if address has claimed
        if (s_addressToHasClaimed[claimAddress]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        bytes32 message = getMessage(claimAddress, amountToClaim);

        // Check signature
        if (!_isValidSignature(claimAddress, message, v, r, s)) {
            revert MerkleAirdrop__SignatureDenied();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(claimAddress, amountToClaim))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__ProofDenied();
        }
        s_addressToHasClaimed[claimAddress] = true;
        i_airdropToken.safeTransfer(claimAddress, amountToClaim);
        emit Claimed(claimAddress, amountToClaim);
    }

    function _isValidSignature(address _account, bytes32 _digest, uint8 _v, bytes32 _r, bytes32 _s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(_digest, _v, _r, _s);
        return actualSigner == _account;
    }

    /**
     * Getter Functions
     */
    function getMessage(address _account, uint256 _amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: _account, amount: _amount})))
        );
    }

    function getMerkelRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (address) {
        return address(i_airdropToken);
    }

    function getDecimals() public pure returns (uint256) {
        return 18;
    }

    function getClaimEligibility(address _address) public view returns (bool) {}

    function getClaimStatus(address _address) public view returns (bool) {
        return s_addressToHasClaimed[_address];
    }
}
