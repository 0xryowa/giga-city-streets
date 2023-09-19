// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {GigaCityStreets} from "../src/GigaCityStreets.sol";
import "operator-filter-registry/OperatorFilterRegistry.sol";

contract GigaCityStreetsTest is Test {

    // Global helpful addresses
    address public owner;
    address public tom = makeAddr("tom");
    address public jerry = makeAddr("jerry");

    // Required contracts
    GigaCityStreets public gigaStreets;
    OperatorFilterRegistry public registry;

    // =============================================================
    //                            SETUP
    // =============================================================

    function setUp() public {
        // new deployed contracts will have Test as owner
        owner = address(this); 

        registry = new OperatorFilterRegistry();
        address registryAddress = address(registry);

        gigaStreets = new GigaCityStreets(registryAddress, 5);

        vm.deal(tom, 1 ether);
        vm.deal(jerry, 1 ether);

        // gigaStreets.setMintPrice(0);
        // gigaStreets.setSupplyCap(5);
        // gigaStreets.setMaxMintPerTx(5);
        // gigaStreets.setMaxMintPerAddress(5);
    }

    // =============================================================
    //                           INIT VALUES
    // =============================================================

    function test_initValues() public {
        assertEq(gigaStreets.mintOpen(), false);
        assertEq(gigaStreets.mintPrice(), 0);
        assertEq(gigaStreets.supplyCap(), 5);
        assertEq(gigaStreets.maxMintPerTx(), 1);
        assertEq(gigaStreets.maxMintPerAddress(), 1);
    }

    // =============================================================
    //                            MINT
    // =============================================================

    function test_mintable_totalSupply() public {
        gigaStreets.setMintOpen(true);
        gigaStreets.setMaxMintPerTx(5);
        gigaStreets.setMaxMintPerAddress(5);
        gigaStreets.setSupplyCap(3);

        // Start prank
        vm.startPrank(tom);
        // Should be ok
        gigaStreets.mintPublic(2);
        // Should revert
        bytes4 err1 = bytes4(keccak256("TotalSupplyExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPublic(2);
        // Should be ok
        gigaStreets.mintPublic(1);
        // Stop prank
        vm.stopPrank();

    }

    function test_mintable_maxMintPerTx() public {
        uint256 txMax = 3;

        gigaStreets.setMintOpen(true);
        gigaStreets.setMaxMintPerTx(txMax);
        gigaStreets.setMaxMintPerAddress(txMax + 1);

        // Start prank
        vm.startPrank(tom);
        // Should be ok
        gigaStreets.mintPublic(1);
        // Should revert
        bytes4 err1 = bytes4(keccak256("TxQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPublic(txMax + 1);
        // Should be ok
        gigaStreets.mintPublic(txMax);
        // Stop prank
        vm.stopPrank();

    }

    function test_mintable_maxMintPerAddress() public {
        uint256 accMax = 3;

        gigaStreets.setMintOpen(true);
        gigaStreets.setMaxMintPerTx(accMax);        
        gigaStreets.setMaxMintPerAddress(accMax);

        // Start prank
        vm.startPrank(tom);
        // Should be ok
        gigaStreets.mintPublic(1);
        // Should revert
        bytes4 err1 = bytes4(keccak256("AddressQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPublic(accMax);
        // Should be ok
        gigaStreets.mintPublic(accMax - 1);
        // Stop prank
        vm.stopPrank();
    }

    function test_mint_publicFree() public {
        // Start prank
        vm.startPrank(tom);
        // Should revert
        bytes4 err1 = bytes4(keccak256("PublicMintOff()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPublic(1);
        // Stop prank
        vm.stopPrank();
        // Should be ok, setting as owner
        gigaStreets.setMintOpen(true);
        // Pranking as tom
        vm.prank(tom);
        // Should be ok
        gigaStreets.mintPublic(1);
    }

    function test_mint_publicPaid() public {
        gigaStreets.setMintOpen(true);
        gigaStreets.setMintPrice(0.01 ether);
        gigaStreets.setMaxMintPerTx(2);
        gigaStreets.setMaxMintPerAddress(2);

        // Start prank
        vm.startPrank(tom);
        // Should revert
        bytes4 err1 = bytes4(keccak256("NoCashForMint()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPublic(1);
        // Should revert
        bytes4 err2 = bytes4(keccak256("NoCashForMint()"));
        vm.expectRevert(abi.encodeWithSelector(err2));
        gigaStreets.mintPublic{value: 0.005 ether}(1);
        // Should be ok
        gigaStreets.mintPublic{value: 0.02 ether}(2);
        // Stop prank
        vm.stopPrank();
    }

    function test_mint_privateUnavailable() public {
        // Should revert
        vm.prank(tom);
        bytes4 err1 = bytes4(keccak256("NoWhitelistSpot()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPrivate(1);
    }

    function test_mint_PrivateAvailable() public {
        gigaStreets.setMaxMintPerTx(2);        
        gigaStreets.setWhitelist(tom, 1);

        // Start prank
        vm.startPrank(tom);
        // Should revert
        bytes4 err1 = bytes4(keccak256("AddressQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err1));
        gigaStreets.mintPrivate(2);
        // Should be ok
        gigaStreets.mintPrivate(1);
        // Stop prank
        vm.stopPrank();

        // Should be ok
        gigaStreets.setWhitelist(tom, 2);

        // Start prank
        vm.startPrank(tom);
        // Should revert
        bytes4 err2 = bytes4(keccak256("AddressQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err2));
        gigaStreets.mintPrivate(2);
        // Should be ok
        gigaStreets.mintPrivate(1);
        // Should revert
        bytes4 err3 = bytes4(keccak256("AddressQuantityExceeded()"));
        vm.expectRevert(abi.encodeWithSelector(err3));
        gigaStreets.mintPrivate(1);
        // Stop prank
        vm.stopPrank();
    }

    // =============================================================
    //                            METADATA
    // =============================================================

    function test_tokenURI() public {
        gigaStreets.setMintOpen(true);
        gigaStreets.setURIPrefix("https://test.com/");
        gigaStreets.setURISuffix(".html");
        
        // Should be ok
        vm.prank(tom);
        gigaStreets.mintPublic(1);
        // Should EQ
        assertEq(gigaStreets.tokenURI(0), "https://test.com/0.html");
        // Should revert
        bytes4 err3 = bytes4(keccak256("TokenDoesNotExist()"));
        vm.expectRevert(abi.encodeWithSelector(err3));
        gigaStreets.tokenURI(10);
    }

    // =============================================================
    //                            MANAGEMENT
    // =============================================================

    function test_management() public {
        gigaStreets.setMintOpen(true);
        assertEq(gigaStreets.mintOpen(), true);

        gigaStreets.setMintPrice(1 ether);
        assertEq(gigaStreets.mintPrice(), 1 ether);

        gigaStreets.setSupplyCap(200);
        assertEq(gigaStreets.supplyCap(), 200);

        gigaStreets.setMaxMintPerTx(2);
        assertEq(gigaStreets.maxMintPerTx(), 2);

        gigaStreets.setMaxMintPerAddress(5);
        assertEq(gigaStreets.maxMintPerAddress(), 5);
    }

    // =============================================================
    //                             OTHERS
    // =============================================================

    function test_withdraw() public {
        uint256 price = 0.3 ether;
        uint256 initialBalance = owner.balance;

        gigaStreets.setMintOpen(true);
        gigaStreets.setMintPrice(price);
        vm.prank(tom);
        gigaStreets.mintPublic{value: price}(1);
        gigaStreets.withdraw();

        assertEq(owner.balance, initialBalance + price);
    }

    // https://ethereum.stackexchange.com/questions/136285/withdraw-fails-in-foundry-test
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}
    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}