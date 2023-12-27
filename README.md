# Blockchain based warranty/purchase record
The below is the structure of the project

### Solidity/Smart Contracts (./contracts/)
- contracts/Receipt.sol -- The contract for the main receipt contract
- contracts/StorageContracts.sol -- The contract used for storing contract addresses

### Frontend/Client/dAPP (./client-1/client/)
A demo flutter application(can be run on Windows/Android/iOS...) is included with the following features
1. View all of the purchases/receipts no matter who issued it
2. Transfer ownership of receipts
3. Trusted/Database of trusted issuers/minters
4. Details of product, such as identifier, activation date, and warranty expiry date
5. Purchasing Products Demo -- REQUIRE THE PYTHON BACKEND

### Backend (./backend)
The demo backend is used to simulate a company server, which customers could buy products from, in this example, it is "ABC Technology Ltd."(Address:0x1ea8Ed0363F1d03C7907cE8D299823Fa3FAa4887)

The backend is written in python and flask for simple and quick setup.

to run the backend, just run the server.py

## Setup and testings
In order to test the project, you must ensure the Ganache is setup and the addresses in both truffle-config, and also the server and the flutter app is configured correctly. At the same time, the private key in the flutter app and server should be modified to fit the ganache environment you are in. The storage contract must first be created. You have to obtain the storage contract address and put it in both the flutter app and also the contract itself (needs recompiling)