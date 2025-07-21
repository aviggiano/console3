# console3

Extended console.log in Solidity for ERC20 tokens and ERC4626 vaults.

## Installation

```bash
forge install aviggiano/console3
```

## Usage

### ERC20 Token Balances

```solidity
import {console3} from "console3.sol";
console3.logERC20(token, accounts);
```

**Output:**
```
                                   account   balance
0xc22B0348e8E4e484B29E161e992b0A1b4D1A50F0         0
0xd4D7b9C047E1B06ccE298c883C1D8B2f642A5d06        11
0x91A224Dc52a2C46293aa51BBbae7AaBa5a49c0ED       204
0x2d208abb10F2FB825e460AeA9cFE58a782558BAa     3_009
0xEF6d40732102D6A804E804C12BdD73dD56cfDEf5    40_016
0xeF3a60961Bb0902df0fbCb6a9c4Ee0233aeCde57   500_025

                          SUM(balanceOf())   543_265
                             totalSupply()   543_265
```

### ERC4626 Vault Positions

```solidity
import {console3} from "console3.sol";
console3.logERC4626(vault, accounts);
```

**Output:**
```
                                   account      shares      assets
0xc22B0348e8E4e484B29E161e992b0A1b4D1A50F0           0           0
0xd4D7b9C047E1B06ccE298c883C1D8B2f642A5d06          11          21
0x91A224Dc52a2C46293aa51BBbae7AaBa5a49c0ED         204         391
0x2d208abb10F2FB825e460AeA9cFE58a782558BAa       3_009       5_778
0xEF6d40732102D6A804E804C12BdD73dD56cfDEf5      40_016      76_846
0xeF3a60961Bb0902df0fbCb6a9c4Ee0233aeCde57     500_025     960_250

                                    SUM(_)     543_265   1_043_286
                                   total()     543_265   1_043_290
```
