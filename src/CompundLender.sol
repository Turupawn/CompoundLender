// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IComet is IERC20 {
    function supply(address asset, uint amount) external;
    function withdraw(address asset, uint amount) external;
}

contract CometLender {
    address public immutable COMET_ADDRESS;
    address public immutable STAKED_TOKEN_ADDRESS;
    address public immutable OWNER;
    mapping(address account => uint amount) public stakeByAccount;
    uint public totalStake;

    constructor(address commetAddress, address stakedTokenAddress) {
        COMET_ADDRESS = commetAddress;
        STAKED_TOKEN_ADDRESS = stakedTokenAddress;
        OWNER = msg.sender;
    }

    function stake(uint amount) public {
        totalStake += amount;
        stakeByAccount[msg.sender] += amount;
        IERC20(STAKED_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount);

        IERC20(STAKED_TOKEN_ADDRESS).approve(COMET_ADDRESS, amount);
        IComet(COMET_ADDRESS).supply(STAKED_TOKEN_ADDRESS, amount);
    }

    function unstake(uint amount) public {
        require(amount <= stakeByAccount[msg.sender], "Not enough stake");
        totalStake -= amount;
        stakeByAccount[msg.sender] -= amount;
        IComet(COMET_ADDRESS).withdraw(STAKED_TOKEN_ADDRESS, amount);
    }

    function yieldEarned() public view returns(uint){
        return IComet(COMET_ADDRESS).balanceOf(address(this)) - totalStake;
    }

    function withdraw(uint amount) public {
        require(msg.sender == OWNER, "Sender is not owner");
        require(amount <= yieldEarned(), "Maximum withdraw exceeded");
        IComet(COMET_ADDRESS).withdraw(STAKED_TOKEN_ADDRESS, amount);
    }
}
