// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IERC4626} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Math} from "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

library console3 {
    uint256 private constant ADDRESS_LENGTH = 42;

    enum ColumnType {
        Address,
        Uint256
    }

    function spaces(uint256 n) internal pure returns (string memory ans) {
        for (uint256 i = 0; i < n; i++) {
            ans = string.concat(ans, " ");
        }
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

    function logERC20(IERC20 token, address[] memory accounts) internal view {
        string memory message = "";
        uint256 maxDigits = digits(token.totalSupply());

        message = string.concat(message, _buildERC20Header(maxDigits));
        message = string.concat(message, _buildERC20Rows(token, accounts, maxDigits));
        message = string.concat(message, _buildERC20Footer(token, accounts, maxDigits));

        console.log(message);
    }

    function _buildERC20Header(uint256 maxDigits) private pure returns (string memory) {
        string memory message = "";
        string[] memory headers = new string[](2);
        headers[0] = "account";
        headers[1] = "balance";

        for (uint256 i = 0; i < headers.length; i++) {
            uint256 s = i == 0
                ? (ADDRESS_LENGTH - 2) - bytes(headers[i]).length
                : 2 + Math.saturatingSub(maxDigits, bytes(headers[i]).length);
            message = string.concat(message, spaces(s), headers[i]);
        }
        return string.concat(message, "\n");
    }

    function _buildERC20Rows(IERC20 token, address[] memory accounts, uint256 maxDigits)
        private
        view
        returns (string memory)
    {
        string memory message = "";

        for (uint256 i = 0; i < accounts.length; i++) {
            message = string.concat(
                message,
                Strings.toChecksumHexString(accounts[i]),
                spaces(2),
                padStart(formatNumberWithUnderscores(token.balanceOf(accounts[i])), maxDigits),
                "\n"
            );
        }
        return message;
    }

    function _buildERC20Footer(IERC20 token, address[] memory accounts, uint256 maxDigits)
        private
        view
        returns (string memory)
    {
        string memory message = "\n";
        string[] memory footers = new string[](2);
        footers[0] = "SUM(balanceOf())";
        footers[1] = "totalSupply()";

        uint256 sum = _calculateERC20Sum(token, accounts);

        for (uint256 i = 0; i < footers.length; i++) {
            message = string.concat(message, _buildERC20FooterRow(footers[i], token, i, sum, maxDigits));
        }
        return message;
    }

    function _buildERC20FooterRow(string memory footerKey, IERC20 token, uint256 index, uint256 sum, uint256 maxDigits)
        private
        view
        returns (string memory)
    {
        uint256 s = (ADDRESS_LENGTH) - bytes(footerKey).length;
        uint256 value = index == 0 ? sum : token.totalSupply();

        return string.concat(
            spaces(s), footerKey, spaces(2), padStart(formatNumberWithUnderscores(value), maxDigits), "\n"
        );
    }

    function _calculateERC20Sum(IERC20 token, address[] memory accounts) private view returns (uint256 sum) {
        for (uint256 i = 0; i < accounts.length; i++) {
            sum += token.balanceOf(accounts[i]);
        }
    }

    function logERC4626(IERC4626 vault, address[] memory accounts) internal view {
        string memory message = "";
        uint256 maxDigits = digits(Math.max(vault.totalSupply(), vault.totalAssets()));

        message = string.concat(message, _buildERC4626Header(maxDigits));
        message = string.concat(message, _buildERC4626Rows(vault, accounts, maxDigits));
        message = string.concat(message, _buildERC4626Footer(vault, accounts, maxDigits));

        console.log(message);
    }

    function _buildERC4626Header(uint256 maxDigits) private pure returns (string memory) {
        string memory message = "";
        string[] memory headers = new string[](3);
        headers[0] = "account";
        headers[1] = "shares";
        headers[2] = "assets";

        for (uint256 i = 0; i < headers.length; i++) {
            uint256 s = i == 0
                ? (ADDRESS_LENGTH - 2) - bytes(headers[i]).length
                : 2 + Math.saturatingSub(maxDigits, bytes(headers[i]).length);
            message = string.concat(message, spaces(s), headers[i]);
        }
        return string.concat(message, "\n");
    }

    function _buildERC4626Rows(IERC4626 vault, address[] memory accounts, uint256 maxDigits)
        private
        view
        returns (string memory)
    {
        string memory message = "";

        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 shares = vault.balanceOf(accounts[i]);
            uint256 assets = vault.convertToAssets(shares);
            message = string.concat(
                message,
                Strings.toChecksumHexString(accounts[i]),
                spaces(2),
                padStart(formatNumberWithUnderscores(shares), maxDigits),
                spaces(2),
                padStart(formatNumberWithUnderscores(assets), maxDigits),
                "\n"
            );
        }
        return message;
    }

    function _buildERC4626Footer(IERC4626 vault, address[] memory accounts, uint256 maxDigits)
        private
        view
        returns (string memory)
    {
        string memory message = "\n";
        string[] memory footers = new string[](2);
        footers[0] = "SUM(_)";
        footers[1] = "total()";

        (uint256 sumShares, uint256 sumAssets) = _calculateERC4626Sums(vault, accounts);

        for (uint256 i = 0; i < footers.length; i++) {
            message = string.concat(message, _buildFooterRow(footers[i], vault, i, sumShares, sumAssets, maxDigits));
        }
        return message;
    }

    function _buildFooterRow(
        string memory footerKey,
        IERC4626 vault,
        uint256 index,
        uint256 sumShares,
        uint256 sumAssets,
        uint256 maxDigits
    ) private view returns (string memory) {
        uint256 s = (ADDRESS_LENGTH) - bytes(footerKey).length;
        (uint256 value0, uint256 value1) = _getERC4626FooterValues(vault, index, sumShares, sumAssets);

        return string.concat(
            spaces(s),
            footerKey,
            spaces(2),
            padStart(formatNumberWithUnderscores(value0), maxDigits),
            spaces(2),
            padStart(formatNumberWithUnderscores(value1), maxDigits),
            "\n"
        );
    }

    function _calculateERC4626Sums(IERC4626 vault, address[] memory accounts)
        private
        view
        returns (uint256 sumShares, uint256 sumAssets)
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            sumShares += vault.balanceOf(accounts[i]);
            sumAssets += vault.convertToAssets(vault.balanceOf(accounts[i]));
        }
    }

    function _getERC4626FooterValues(IERC4626 vault, uint256 index, uint256 sumShares, uint256 sumAssets)
        private
        view
        returns (uint256, uint256)
    {
        if (index == 0) return (sumShares, sumAssets);
        else return (vault.totalSupply(), vault.totalAssets());
    }
}
