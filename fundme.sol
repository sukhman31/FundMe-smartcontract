//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
/*interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
} */

contract FundMe{

    using SafeMathChainlink for uint256;

    //This contract will accept payment
    //payable is a keyword which makes function to be able to pay for things

    mapping(address => uint256) public addresstoamountfunded;
    
    //we are making this address array for storing all funders' addresses so
    //that we can reset their sent value after withdrawing

    address[] public funders;
    address public owner;

    //the constructor which is automatically called when running a contract
    //will set us as the owner so all the funds are transferred to our account

    constructor() public{
        owner = msg.sender;
    }

    function fund() public payable{
        uint256 minimumusd = 1*10**18;
        require(getconversionrate(msg.value)>=minimumusd, "Insufficient");
        addresstoamountfunded[msg.sender]+=msg.value;
        funders.push(msg.sender);
    }

    //need to know ETH->USD conversion rate
    //we can get it from decntralised oracle networks

    function getversion() public view returns(uint256){
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return pricefeed.version();
    }

    function getprice() public view returns(uint256){
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,)
        =pricefeed.latestRoundData();
        return uint256(answer*10000000000);
    }

    function getconversionrate(uint256 ethamount) public view returns(uint256){
        uint256 ethprice = getprice();
        uint256 ethamountinusd = (ethprice*ethamount)/1000000000000000000;
        return ethamountinusd;
        //0.000000117365622191 USD = 1 GWEI
    }

    //modifiers are used to change the behavior of a function in a declarative way
    modifier onlyOwner{
        require (msg.sender == owner);
        _;
    }

    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);
        for(uint256 funderindex=0;funderindex<funders.length;funderindex++){
            address funder = funders[funderindex];
            addresstoamountfunded[funder]=0;
        }
        //setting funders to a new blank address array
        funders = new address[](0);
    }
}