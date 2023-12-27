library client.blockchain;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

final String _rpcUrl = "http://localhost:7545";
final String _wsUrl = "ws://localhost:7545/";
String _privateKey =
    "0x3c0c8b6630e427cde7a5ecfe0249927115ef16cb69c435dc43025dcc65757b5d";
//please change this based on the address of the storage
final String storageAddress = "0x97f3797088BDad91Bd90F4D9a84C0b914911f2aD";
var apiUrl = _rpcUrl; //Replace with your API
var httpClient = Client();
Web3Client ethClient = Web3Client(apiUrl, httpClient);
var credentials = EthPrivateKey.fromHex(_privateKey);
var address = credentials.address;
void ChangeAcconts(int index) {
  var keys = [
    "0x3c0c8b6630e427cde7a5ecfe0249927115ef16cb69c435dc43025dcc65757b5d",
    "0xc4be64989bd59499fd4d039c3e8d06ce3ed907f7bea193722a8cad29dd678d0a"
  ];
  _privateKey = keys[index];
}

Future getMyContracts() async {
  var contracts = await loadContracts();
  var myContracts = [];
  for (var cont in contracts) {
    cont = cont.toString();
    var con = await getReceiptContract(cont);
    var owner = await callFunction(con, "owner");
    if (owner[0] == address) {
      var productInfo = await callFunction(con, "getProductInfo_Customer");
      print("Found contract: " + cont);
      myContracts.add([cont, productInfo[0], productInfo[1]]);
    }
  }
  return myContracts;
}

Future<List> loadContracts() async {
  var addr = await getContracts();
  return addr[0];
}

Future<DeployedContract> getReceiptContract(String address) async {
  //obtain our smart contract using rootbundle to access our json file
  String abiFile = await rootBundle.loadString("assets/Receipt.json");
  //print(abiFile);
  var abi = jsonDecode(abiFile)["abi"];
  var abiCode = jsonEncode(abi);
  final contract = DeployedContract(ContractAbi.fromJson(abiCode, "Receipt"),
      EthereumAddress.fromHex(address));

  return contract;
}

Future<DeployedContract> getContract() async {
  //obtain our smart contract using rootbundle to access our json file
  String abiFile = await rootBundle.loadString("assets/StorageContract.json");
  //print(abiFile);
  var abi = jsonDecode(abiFile)["abi"];
  var abiCode = jsonEncode(abi);
  final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, "StorageContract"),
      EthereumAddress.fromHex(storageAddress));

  return contract;
}

Future getContracts() async {
  final contract = await getContract();
  final function = contract.function("getContractAddresses");
  final result =
      await ethClient.call(contract: contract, function: function, params: []);
  return result;
}

Future<List<dynamic>> callFunction(
    DeployedContract contract, String name) async {
  final function = contract.function(name);
  final result = await ethClient.call(
    sender: address,
    contract: contract,
    function: function,
    params: [],
  );
  return result;
}
