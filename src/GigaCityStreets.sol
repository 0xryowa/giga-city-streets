// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/ERC721A.sol";
import "operator-filter-registry/UpdatableOperatorFilterer.sol";
import "solmate/auth/Owned.sol";
// import "operator-filter-registry/OperatorFilterer.sol";

contract GigaCityStreets is UpdatableOperatorFilterer(0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,false), ERC721A, Owned {

    constructor() ERC721A("Giga City Streets", "GCS") Owned(msg.sender) {}

}