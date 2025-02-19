// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakeToken is ERC20 {

    constructor(uint256 initialSupply) ERC20("StakeToken", "SKT") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public pure override returns(uint8){
        return 0;
    }
}