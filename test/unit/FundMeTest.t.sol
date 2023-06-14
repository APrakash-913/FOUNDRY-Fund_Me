// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // 🥇 Always the 1st thing to in Test File
    FundMe fundMe;

    // 🎁 "makeAddr("string")" will return a dummy address for testing purpose.
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10000 ether;
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // ⚠️ We need to create "DeployFundMe" contract.
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // ⬇️ CHEATCODE: Sets the balance of an address XX to newBalance.
        vm.deal(USER, STARTING_BALANCE);
    }

    // 🧪 Tests
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.i_owner()); // 🚀 FundMeTest -> deploy the "FundMe" contract over here: So, "FundMeTest" is OWNER.
        console.log(msg.sender); // 🚀 msg.sender -> "us" who is running this contract.
        console.log(address(this)); // 🚀 msg.sender -> "us" who is running this contract.
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    /**
     * Things to do to work with addresses outside our system:
     * 1. UNIT:
     *      -> Testing a specific part of code.
     * 2. INTEGRATION:
     *      -> Testing how our code works with other part of code.
     * 3. FORKED:
     *      -> Testing code on a simulated real env.
     * 4. INTEGRATION:
     *      -> Testing code in real env. that is not production.
     */
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFails() public {
        vm.expectRevert(); // 🕵️ Next Line should revert.
        fundMe.fund(); // ⚠️ I'm sending 0 ETH over here.
    }

    function testFundUpdateValidTxn() public {
        // ⬇️ will ensure that function is called by USER(= msg.sender)
        vm.prank(USER);
        // ⚠️ I'm sending 1 eth (1e18 wei) over here.
        fundMe.fund{value: SEND_VALUE}();
        // console.log(fundMe.getAddressToAmountFunded(address(this)));
        // console.log(fundMe.getFunder(0));
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        // 1️⃣ Arrange
        uint256 balanceOfOwnerStart = fundMe.getOwner().balance;
        uint256 balanceOfFundMeStart = address(fundMe).balance;

        // 2️⃣ Act
        // uint256 gasStart = gasleft();

        // vm.txGasPrice(GAS_PRICE); // 🧑🏻‍💻 cheatcode
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // 3️⃣ Assert
        uint256 balanceOfOwnerEnd = fundMe.getOwner().balance;
        uint256 balanceOfFundMeEnd = address(fundMe).balance;

        assertEq(balanceOfFundMeEnd, 0);
        assertEq(balanceOfOwnerStart + balanceOfFundMeStart, balanceOfOwnerEnd);
    }

    function testWithdrawWithMultipleFunder() public funded {
        // 1️⃣ Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            // 🫱🏻‍🫲🏻 vm.prank -> new address
            // 🫱🏻‍🫲🏻 vm.deal
            hoax(address(i), SEND_VALUE);
            // fund FundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startBalanceOfOwner = fundMe.getOwner().balance;
        uint256 startBalanceOfFundMe = address(fundMe).balance;

        // 2️⃣ Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // 3️⃣ Assert
        uint256 balanceOfOwnerEnd = fundMe.getOwner().balance;
        uint256 balanceOfFundMeEnd = address(fundMe).balance;

        assertEq(balanceOfFundMeEnd, 0);
        assertEq(startBalanceOfFundMe + startBalanceOfOwner, balanceOfOwnerEnd);
    }

    function testWithdrawWithMultipleFunderCheaper() public funded {
        // 1️⃣ Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            // 🫱🏻‍🫲🏻 vm.prank -> new address
            // 🫱🏻‍🫲🏻 vm.deal
            hoax(address(i), SEND_VALUE);
            // fund FundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startBalanceOfOwner = fundMe.getOwner().balance;
        uint256 startBalanceOfFundMe = address(fundMe).balance;

        // 2️⃣ Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // 3️⃣ Assert
        uint256 balanceOfOwnerEnd = fundMe.getOwner().balance;
        uint256 balanceOfFundMeEnd = address(fundMe).balance;

        assertEq(balanceOfFundMeEnd, 0);
        assertEq(startBalanceOfFundMe + startBalanceOfOwner, balanceOfOwnerEnd);
    }
}
