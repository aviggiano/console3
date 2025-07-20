// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

library console3 {
    function logMessage(string memory label, IERC20 token, address[] memory accounts)
        internal
        view
        returns (string memory)
    {
        string memory message = "";

        message = string.concat(message, "Account", "Balance", "\n");
        for (uint256 i = 0; i < accounts.length; i++) {
            message = string.concat(
                message, Strings.toHexString(accounts[i]), ": ", Strings.toString(token.balanceOf(accounts[i])), "\n"
            );
        }

        return message;
    }

    function log(string memory label, IERC20 token, address[] memory accounts) internal view {
        console.log(label, logMessage(label, token, accounts));
    }
}
