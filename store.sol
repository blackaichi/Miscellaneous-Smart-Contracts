// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Uniswap {
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;
    
    IUniswapV2Router02 public uniswapRouter;
    address private DaiKovan = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    
    ERC20 constant internal dai = ERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);
    
    /**
     * Constructor of uniswapRouter
     */
    constructor() {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }
    
    /**
     * Converts ETH to DAI using Uniswap pools
     * @param daiAmount Amount of DAI that we want
     */
    function convertEthToDai(uint daiAmount) public payable {
        uint deadline = block.timestamp + 15; 
        uniswapRouter.swapETHForExactTokens{ value: msg.value }(daiAmount, getPathForETHtoDAI(), address(this), deadline);
        
        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        transfer(msg.sender, dai.balanceOf(address(this)));
        require(success, "refund failed");
    }
    
    /**
     * Transfers the DAI that we swapped to the sender of ETH
     * @param to The receiver address of the DAI
     * @param value The quantity of DAI that we want to send
     */
    function transfer(address to, uint256 value) private {
        dai.transferFrom(address(this), to, value);
    }
    
    /**
     * Get the estimated DAI that we can acquire with the ETH sent
     * @param daiAmount Amount of DAI that we want
     */
    function getEstimatedETHforDAI(uint daiAmount) public view returns (uint[] memory) {
        return uniswapRouter.getAmountsIn(daiAmount, getPathForETHtoDAI());
    }
    
    /**
     * returns the address of DAI and the uniswap router
     */
    function getPathForETHtoDAI() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = DaiKovan;
        
        return path;
    }
    
    // important to receive ETH
    receive() payable external {}
}