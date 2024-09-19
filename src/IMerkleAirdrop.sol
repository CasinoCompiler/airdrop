// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IMerkleAirdrop {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed claimAddress, uint256 indexed amountClaimed);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function claim(address addressToClaim, uint256 amountToClaim, bytes32[] calldata merkleProof) external;
}
