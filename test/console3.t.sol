// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {console3} from "../src/console3.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {ERC4626Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC4626Mock.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC4626} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol";

contract console3Test is Test {
    ERC20Mock public token1;
    ERC20Mock public token2;
    ERC4626Mock public vault;
    address[] public accounts;

    function setUp() public {
        token1 = new ERC20Mock();
        token2 = new ERC20Mock();
        vault = new ERC4626Mock(address(token2));

        accounts = new address[](6);
        uint256 amount;
        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i] = makeAddr(string.concat("account", Strings.toString(i)));

            amount = i * (10 ** i + i);
            token1.mint(accounts[i], amount);

            token2.mint(accounts[i], amount);
            vm.prank(accounts[i]);
            token2.approve(address(vault), amount);
            vm.prank(accounts[i]);
            vault.deposit(amount, accounts[i]);
        }
        token2.mint(address(vault), amount);
    }

    function test_logERC20() public view {
        console3.logERC20(token1, accounts);
    }

    function test_logERC4626() public view {
        console3.logERC4626(IERC4626(address(vault)), accounts);
    }
}
