// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughETH();
error FundMe__CallFailed();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // we're dealing with 18 decimal places.

    address[] private s_funders;
    mapping(address funder => uint256 fundedAmount)
        private s_addressToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address _pricefeed) {
        // ⚠️ using the price feed provided by the chainlink library for different BLOCKCHAIN....
        // 🚀 So, we need to give PriceFeed address as an Input Parameter to Deploy the Contract.
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_pricefeed);
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender not owner!!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function fund() public payable {
        // require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        if (msg.value.getConversionRate(s_priceFeed) <= MINIMUM_USD) {
            revert FundMe__NotEnoughETH();
        }
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    // 📲 CHEAPER_WITHDRAW()
    function cheaperWithdraw() public onlyOwner {
        uint256 length = s_funders.length;
        for (uint256 funderIndex; funderIndex < length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess /*bytes memory returnedData*/, ) = payable(msg.sender)
            .call{value: address(this).balance}("");
        // require(callSuccess, "Call Failed");
        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Must be OWNER!!");
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // // Transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");
        // call
        (bool callSuccess /*bytes memory returnedData*/, ) = payable(msg.sender)
            .call{value: address(this).balance}("");
        // require(callSuccess, "Call Failed");
        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    // If someone sends ETH without specifying/calling the "fund()"
    // Ex. Sending the funds directly to "This Contract Address" using "Metamask"

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //////////
    // VIEW //
    //////////
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
