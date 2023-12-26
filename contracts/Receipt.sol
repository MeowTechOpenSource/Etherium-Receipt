// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StorageContract.sol";
contract Receipt is ERC721, ERC721Enumerable, Ownable {
    uint256 private _nextTokenId;
    address public immutable issuer;
    uint256 private warranty;
    uint256 private immutable effectiveTime;
    string private productName;
    string private productIdentifier;
    StorageContract private storageContract;
    constructor(address initialOwner,string memory _productName,
        string memory _productIdentifier,
        uint256 _warrantyDates)
        ERC721("Receipt", "RCPT")
        Ownable(initialOwner)
    {
        // stored the list of contracts is a storage on blockchain
        storageContract = StorageContract(0x97f3797088BDad91Bd90F4D9a84C0b914911f2aD);
        //_safeMint(initialOwner, _nextTokenId);
        issuer = msg.sender;
        effectiveTime = block.timestamp;
        //effectiveTime = 0;
        productName = _productName;
        productIdentifier = _productIdentifier;
        warranty = _warrantyDates;
        _nextTokenId++;
        _storeNewContract(address(this));
    }
    function _storeNewContract(address _contractAddress) public {
        storageContract.storeContractAddress(_contractAddress);
    }

    function getAllContractAddresses() public view returns (address[] memory) {
        return storageContract.getContractAddresses();
    }
    modifier onlyIssuer() {
        require(
            msg.sender == issuer,
            "Only the minter can call this function."
        );
        _;
    }
    function getOwnedTokens(address account) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(account);
        uint256[] memory tokenIds = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(account, i);
        }

        return tokenIds;
    }
    function getWarranty() external view returns (uint256) {
        return warranty;
    }
    function getEffectiveTime() external view returns (uint256) {
        return effectiveTime;
    }
    function getProductInfo() public onlyIssuer view returns (string memory, string memory){
        return (productName, productIdentifier);
    }
    function getProductInfo_Customer() public onlyOwner view returns (string memory, string memory){
        return (productName, productIdentifier);
    }
    function updateWarranty(uint256 addWarrantyMonths) public onlyIssuer returns(uint256 newWarranty){
        require(
            addWarrantyMonths >=0,
            "The added warranty months should be a positive value"
        );
        warranty += addWarrantyMonths;
        newWarranty = warranty;
    }
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
