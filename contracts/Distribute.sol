// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Distribute is Ownable {

    struct DistributeParam{
        address to;
        uint    amount;
    }

    mapping (address => uint) distributes;
    uint public network;

    receive() external payable {
    }

    constructor(uint _network) payable {
        network = _network;
    }

    function distribute() public view returns (uint) {
        return distributes[msg.sender];
    }

    function withdraw() public {
        require(distributes[msg.sender] != 0, "no distribute");
        TransferHelper.safeTransferETH(msg.sender, distributes[msg.sender]);
        distributes[msg.sender] = 0;
    }

    function setDistribute(DistributeParam[] memory dbs) public onlyOwner {
        for (uint256 i = 0; dbs.length != 0 && i < dbs.length; i++){
            distributes[dbs[i].to] = dbs[i].amount;
        } 
    }

}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

