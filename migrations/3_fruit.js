const Receipt = artifacts.require("./Receipt.sol");
const Storage = artifacts.require("./StorageContract.sol");
module.exports = function(deployer) {
  // Comment This Out
  const initialOwner = "0x6A04A136b20e0985B05f8cf0E1cDD7FD210d2062"
  const productName = "Product Name";
  const productIdentifier = "Product Identifier";
  const warrantyDates = 10;
  // End Of Comment This Out
  //deployer.deploy(Storage) -- Uncomment this to deploy the storage
  //Comment the below
  deployer.deploy(Receipt, initialOwner, productName, productIdentifier, warrantyDates);
  
};