import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/blockchain.dart';
import 'package:client/trusted.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class Info extends StatefulWidget {
  const Info({super.key, required this.address});
  final address;
  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  List<dynamic> productInfo = ["", ""];
  var effectiveTime = DateTime.now();
  var warranty = 0;
  final textController = TextEditingController();
  var issuer = "0x00";
  @override
  void initState() {
    load();
  }

  Future<void> load() async {
    var contract = await getReceiptContract(widget.address);
    productInfo = await callFunction(contract, "getProductInfo_Customer");
    var tmp = ((await callFunction(contract, "getEffectiveTime"))[0] as BigInt)
        .toDouble();
    effectiveTime = DateTime.fromMillisecondsSinceEpoch(tmp.toInt() * 1000);
    warranty = ((await callFunction(contract, "getWarranty"))[0] as BigInt)
        .toDouble()
        .toInt();
    print(warranty);
    issuer = (await callFunction(contract, "issuer"))[0].toString();
    setState(() {});
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Transfer Contract'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    // Get address from text field
                    final address = textController.text;
                    var contract = await getReceiptContract(widget.address);
                    await ethClient.sendTransaction(
                        credentials,
                        Transaction.callContract(
                          contract: contract,
                          function: contract.function("transferOwnership"),
                          parameters: [EthereumAddress.fromHex(address)],
                        ),
                        chainId: 1337);

                    // Pop dialog
                    Navigator.pop(context);
                  },
                  child: Text('Transfer'))
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productInfo[0],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Issued By: " + getFirmName(issuer.toString()).toString(),
                    style: TextStyle(
                        color: checkIfTrusted(issuer.toString())
                            ? Colors.green
                            : Colors.red),
                  ),
                  Text(
                    "S/N: " + productInfo[1],
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Contract Address: " + widget.address,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Effective Date: " + effectiveTime.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Warranty Expires At: " +
                        effectiveTime
                            .add(Duration(days: warranty * 31))
                            .toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.white),
            width: double.infinity,
          ),
        ),
        TextButton(
            onPressed: () {
              _showDialog(context);
            },
            child: Text("Transfer")),
        TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ExtendWarrantyDialog(
                    address: widget.address,
                  );
                },
              );
            },
            child: Text("Add warranty"))
      ]),
      backgroundColor: Color.fromARGB(255, 241, 243, 245),
    );
  }
}

class ExtendWarrantyDialog extends StatefulWidget {
  const ExtendWarrantyDialog({super.key, required this.address});
  final address;
  @override
  State<ExtendWarrantyDialog> createState() => _ExtendWarrantyDialogState();
}

class _ExtendWarrantyDialogState extends State<ExtendWarrantyDialog> {
  TextEditingController _monthsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _monthsController = TextEditingController();
  }

  @override
  void dispose() {
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Extend Warranty'),
      content: TextField(
        controller: _monthsController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Enter the number of months',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Extend'),
          onPressed: () {
            // Perform the extension logic here
            int months = int.parse(_monthsController.text);
            if (months != null && months > 0) {
              // do the job
              String url = 'http://localhost:5000/buy/warranty';
              Map<String, String> headers = {
                'Content-Type': 'application/json',
              };

              Map<String, dynamic> requestBody = {
                'contractaddr': widget.address,
                'months': months,
              };
              http
                  .post(
                Uri.parse(url),
                headers: headers,
                body: jsonEncode(requestBody),
              )
                  .then((value) {
                print(value.statusCode);
                Navigator.of(context).pop();
              });
              Navigator.of(context).pop();
            } else {
              // Invalid input, display an error message
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Invalid Input'),
                    content: Text('Please enter a valid number of months.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
