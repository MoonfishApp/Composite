pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract <#__project_name#>  is ERC20 {
    string public name = "<#Token Name#>";
    string public symbol = "<#Token Symbol#>";
    uint8 public decimals = <#Decimals#>;
    uint public initial_supply = <#Initial Supply#>;


    constructor() public {
        totalSupply_ = initial_supply;
        balances[msg.sender] = initial_supply;
    }
}
