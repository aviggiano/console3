// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

library console3 {
    enum ColumnType {
        Account,
        Uint256
    }

    function spaces(uint256 n) internal pure returns (string memory ans) {
        for (uint256 i = 0; i < n; i++) {
            ans = string.concat(ans, " ");
        }
    }

    function maxBalanceOf(IERC20 token, address[] memory accounts) internal view returns (uint256) {
        uint256 max = 0;
        for (uint256 i = 0; i < accounts.length; i++) {
            max = max > token.balanceOf(accounts[i]) ? max : token.balanceOf(accounts[i]);
        }
        return max;
    }

    function digits(uint256 n) internal pure returns (uint256) {
        uint256 ans = 0;
        while (n > 0) {
            n /= 10;
            ans++;
            if (ans % 3 == 0) {
                ans++;
            }
        }
        return ans;
    }

    function formatNumberWithUnderscores(uint256 n) internal pure returns (string memory) {
        if (n == 0) return "0";

        string memory result = "";
        uint256 count = 0;

        while (n > 0) {
            if (count > 0 && count % 3 == 0) {
                result = string.concat("_", result);
            }
            result = string.concat(Strings.toString(n % 10), result);
            n /= 10;
            count++;
        }

        return result;
    }

    function padStart(string memory s, uint256 n) internal pure returns (string memory) {
        return string.concat(spaces(n > bytes(s).length ? n - bytes(s).length : 0), s);
    }

    function log(IERC20 token, address[] memory accounts) internal view {
        string memory message = "";

        uint256 maxDigits = digits(maxBalanceOf(token, accounts));

        string[] memory headers = new string[](2);
        headers[0] = "account";
        headers[1] = "balance";
        ColumnType[] memory columnTypes = new ColumnType[](2);
        columnTypes[0] = ColumnType.Account;
        columnTypes[1] = ColumnType.Uint256;

        string[] memory footers = new string[](2);
        footers[0] = "SUM(balanceOf())";
        footers[1] = "totalSupply()";

        for (uint256 i = 0; i < headers.length; i++) {
            uint256 s = i == 0 ? 40 - bytes(headers[i]).length : 2;
            message = string.concat(message, spaces(s), headers[i]);
        }
        message = string.concat(message, "\n");

        uint256 sum = 0;
        for (uint256 i = 0; i < accounts.length; i++) {
            message = string.concat(
                message,
                Strings.toChecksumHexString(accounts[i]),
                spaces(2),
                padStart(formatNumberWithUnderscores(token.balanceOf(accounts[i])), maxDigits),
                "\n"
            );
            sum += token.balanceOf(accounts[i]);
        }
        message = string.concat(message, "\n");
        for (uint256 i = 0; i < footers.length; i++) {
            uint256 s = 42 - bytes(footers[i]).length;
            string memory key = footers[i];
            uint256 value = i == 0 ? sum : token.totalSupply();
            message = string.concat(
                message, spaces(s), key, spaces(2), padStart(formatNumberWithUnderscores(value), maxDigits), "\n"
            );
        }

        console.log(message);
    }
}
