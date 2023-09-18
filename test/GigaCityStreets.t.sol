// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {GigaCityStreets} from "../src/GigaCityStreets.sol";
import "operator-filter-registry/OperatorFilterRegistry.sol";

contract GigaCityStreetsTest is Test {
    address public owner;
    address public tom = makeAddr("tom");
    address public jerry = makeAddr("jerry");

    GigaCityStreets public gigaStreets;
    OperatorFilterRegistry public registry;

    function setUp() public {
        // new deployed contracts will have Test as owner
        owner = address(this); 

        registry = new OperatorFilterRegistry();
        address registryAddress = address(registry);

        gigaStreets = new GigaCityStreets(registryAddress);

        gigaStreets.setMintPrice(0);
        gigaStreets.setSupplyCap(5);
        gigaStreets.setMaxMintPerTx(5);
        gigaStreets.setMaxMintPerAddress(5);
    }

    function test_initValues() public {
        assertEq(gigaStreets.mintOpen(), false);
        assertEq(gigaStreets.mintPrice(), 0);
        assertEq(gigaStreets.supplyCap(), 5);
    }

    function test_mintable_totalSupply() public {
        gigaStreets.setMintOpen(true);

        vm.prank(tom);
        gigaStreets.mintPublic(2);

        bytes4 err1 = bytes4(keccak256("TotalSupplyExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err1));

        vm.prank(jerry);
        gigaStreets.mintPublic(4);

    }

    function test_mintable_maxMintPerTx() public {
        gigaStreets.setMintOpen(true);
        gigaStreets.setMaxMintPerTx(3);

        bytes4 err2 = bytes4(keccak256("TxQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err2));

        vm.prank(tom);
        gigaStreets.mintPublic(4);

    }

    function test_mintable_maxMintPerAddress() public {
        gigaStreets.setMintOpen(true);
        gigaStreets.setMaxMintPerAddress(3);
        gigaStreets.setMaxMintPerTx(5);


        vm.prank(tom);
        gigaStreets.mintPublic(2);

        bytes4 err3 = bytes4(keccak256("AddressQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err3));

        vm.prank(tom);
        gigaStreets.mintPublic(2);
    }

    function test_mintPublic() public {
        bytes4 selector = bytes4(keccak256("PublicMintOff()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        
        vm.prank(tom);
        gigaStreets.mintPublic(1);

        gigaStreets.setMintOpen(true);

        vm.prank(tom);
        gigaStreets.mintPublic(1);
    }

    // function test_Increment() public {
    //     bytes4 selector = bytes4(keccak256("TokenDoesNotExist()"));
    //     vm.expectRevert(abi.encodeWithSelector(selector));
    //     gigaStreets.tokenURI(0);
        
    //     vm.prank(tom);
    //     gigaStreets.mint(1); 

    //     vm.prank(jerry);
    //     gigaStreets.mint(1); 

    //     gigaStreets.tokenURI(0);

    //     assertEq(gigaStreets.ownerOf(0), tom);
    //     assertEq(gigaStreets.ownerOf(1), jerry);
    // }
}