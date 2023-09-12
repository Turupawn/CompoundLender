// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CompundLender.sol";

contract CometLenderTest is Test {
    CometLender public cometLender;
    address COMET_ADDRESS = 0x9c4ec768c28520B50860ea7a15bd7213a9fF58bf;
    address USDC_TOKEN = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address USDC_HOLDER = 0xb6F5414bAb8d5ad8F33E37591C02f7284E974FcB;

    function setUp() public {
        cometLender = new CometLender(
            COMET_ADDRESS,
            USDC_TOKEN
        );
    }

    function testEarnYield() public {
        vm.startPrank(USDC_HOLDER);

        uint deposit_amount = 500000; // this is 0.5

        IERC20(USDC_TOKEN).approve(address(cometLender), deposit_amount);
        cometLender.stake(deposit_amount);

        skip(50 days);


        cometLender.unstake(deposit_amount);

        vm.stopPrank();

        cometLender.withdraw(0.000001 ether);
    }
}
