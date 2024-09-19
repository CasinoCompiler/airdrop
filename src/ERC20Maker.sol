// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@oz/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@oz/contracts/access/Ownable.sol";

contract ERC20Maker is ERC20, Ownable {
    constructor(string memory tokenName, string memory tokenSymbol) ERC20(tokenName, tokenSymbol) Ownable(msg.sender) {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
