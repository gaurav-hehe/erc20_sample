// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract SampleCoin is ERC20 {
    uint256 private _totalSupply = 100;

    constructor () ERC20('SampleCoin', 'SAM') {
        _mint(msg.sender, 100);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

}
