// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract StorageContract {
    address[] public contractAddresses;

    function storeContractAddress(address _contractAddress) public {
        contractAddresses.push(_contractAddress);
    }

    function getContractAddresses() public view returns (address[] memory) {
        return contractAddresses;
    }
}