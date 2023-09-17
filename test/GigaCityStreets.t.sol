// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {GigaCityStreets} from "../src/GigaCityStreets.sol";

contract GigaCityStreetsTest is Test {
    address public owner;
    address public tom = makeAddr("tom");
    address public jerry = makeAddr("jerry");

    GigaCityStreets public gigaStreets;

    function setUp() public {
        // new deployed contracts will have Test as owner
        owner = address(this); 

        gigaStreets = new GigaCityStreets();
    }

    function test_Increment() public {
        bytes4 selector = bytes4(keccak256("TokenDoesNotExist()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        gigaStreets.tokenURI(0);
        
        vm.prank(tom);
        gigaStreets.mint(1); 

        vm.prank(jerry);
        gigaStreets.mint(1); 

        gigaStreets.tokenURI(0);

        assertEq(gigaStreets.ownerOf(0), tom);
        assertEq(gigaStreets.ownerOf(1), jerry);
    }
}