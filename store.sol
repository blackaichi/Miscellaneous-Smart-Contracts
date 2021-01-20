// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./exchange_ETHDAI.sol";

contract storageETH {

    AggregatorV3Interface internal priceETHUSD;
    
    address payable myadress = 0x3d3d17b903f6E33eBE3156521d40b309616D1d45;
    uint256 myETH = 0;
    address payable uniswapaddr = 0x22F128b91428c8AC715dc2Efe9aff597a0776B26;
    Uniswap u = Uniswap(uniswapaddr);

    /**
     * Network: Kovan
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor() {
        priceETHUSD = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }

    /**
     * Returns the latest price
     */
    function getPriceETH() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceETHUSD.latestRoundData();
        return price/100000000;
    }

    /**
     * Returns how many ETH we have in the contract
     */
    function howManyETH() public view returns (uint256) {
        return myETH;
    }

    /*
     * Stores the sent amount.
     * @param payee The destination address of the funds.
     */
    function deposit() public payable {
        uint256 amount = msg.value;
        myETH = myETH + amount;
    }
    
    /*
     * Withdraw accumulated balance for a payee.
     * @param payee The address whose funds will be withdrawn and transferred to.
     */
    function withdraw(uint256 payment) public {
        require(myETH - payment > 0, "Insufficient funds to allow transfer");
        myETH = myETH - payment;
        
        myadress.transfer(payment);
    }
    
    /**
     * Convert ETH sent to DAI on uniswap
     * @param daiAmount Amount of DAI that we want
     * @param valueSend Amount of ETH sent to swap, the remaining will be returned
     */
    function convertToDai(uint daiAmount, uint valueSend) public payable {
        u.convertEthToDai{value:valueSend}(daiAmount);
    }
    
    /**
     * Get the estimated DAI that we can acquire with the ETH sent
     * @param daiAmount Amount of DAI that we want
     */
    function estimatedDai(uint daiAmount) public view returns (uint[] memory) {
        return u.getEstimatedETHforDAI(daiAmount);
    }
    
    receive() payable external {}
}
