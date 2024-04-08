// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract ERC4626NonVulnerable is ERC4626 {

    constructor(string memory _name, string memory _symbol, IERC20 _asset) ERC4626(_asset) ERC20(_name, _symbol) {

        // Mint dead shares
        _mint(address(this), 1000 * 1e18);  
    }

}
