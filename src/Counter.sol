// SPDX-License-Identifier: MIT

import "erc721a/extensions/ERC721AQueryable.sol";

pragma solidity ^0.8.18;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
