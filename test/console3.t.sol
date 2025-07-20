// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {console3} from "../src/console3.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract console3Test is Test {
    ERC20Mock public token;
    address[] public accounts;

    function setUp() public {
        token = new ERC20Mock();

        accounts = new address[](3);
        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i] = makeAddr(string.concat("account", Strings.toString(i)));
            token.mint(accounts[i], 1e18 * (i + 1));
        }
    }

    function test_log() public {
        string memory message = console3.logMessage("ERC20Mock", token, accounts);
        console3.log("ERC20Mock", token, accounts);
    }
}
