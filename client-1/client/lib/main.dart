import 'dart:convert';

import 'package:client/info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'blockchain.dart';

void main() {
  runApp(MaterialApp(
    home: MainPage(),
    theme: ThemeData(useMaterial3: true),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var selected = "0x0";
  var userID = 0;
  var accounts = [
    "0x6A04A136b20e0985B05f8cf0E1cDD7FD210d2062",
    "0xcf9Ca99a3bC099713C35474bB7D14fbBD0F507A0"
  ];
  List<dynamic> displayOptions = ["", ""];
  List<dynamic> contracts = [
    ["0x0", "", ""]
  ];
  @override
  initState() {
    super.initState();

    getMyContracts().then((value) {
      setState(() {
        contracts = value;
        selected = value[0][0];
      });
    });

    // You can now call rpc methods. This one will query the amount of Ether you own
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(accounts[userID]),
        actions: [
          IconButton(
              onPressed: () {
                if (userID == 0) {
                  userID = 1;
                } else {
                  userID = 0;
                }
                ChangeAcconts(userID);
                setState(() {});
                getMyContracts().then((value) {
                  setState(() {
                    contracts = value;
                    selected = value[0][0];
                  });
                });
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton(
              value: selected,
              hint: Text("My Products"),
              items: contracts.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value[0],
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.phone_android_rounded),
                    SizedBox(
                      width: 20,
                    ),
                    Text(value[1])
                  ]),
                );
              }).toList(),
              onChanged: (value) async {
                selected = value;
                var con = await getReceiptContract(selected);
                displayOptions =
                    await callFunction(con, "getProductInfo_Customer");
                setState(() {});
              }),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Info(
                        address: selected,
                      )),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    size: 80,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayOptions[0],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(selected),
                    ],
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white),
              height: 100,
              width: double.infinity,
            ),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MyDialog();
            },
          ).then((value) {
            setState(() {});
          });
        },
        child: Icon(Icons.add_rounded),
      ),
      backgroundColor: Color.fromARGB(255, 241, 243, 245),
    );
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  String? selectedPhoneModel;
  String? selectedRamStorage;
  String? selectedColor;

  List<String> phoneModels = ['Hova 12', 'Hova 12 Pro', 'Hova 12 Ultra'];
  List<String> ramStorageSizes = ['8GB+256GB', "12GB+512GB", "12GB+1TB"];
  List<String> colors = [
    'Blue',
    'Pink',
    'Yellow',
    'Green',
    'Space Grey',
    'Gold'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Phone Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedPhoneModel,
            onChanged: (value) {
              setState(() {
                selectedPhoneModel = value!;
              });
            },
            items: phoneModels.map((String model) {
              return DropdownMenuItem<String>(
                value: model,
                child: Text(model),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Phone Model',
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedRamStorage,
            onChanged: (value) {
              setState(() {
                selectedRamStorage = value!;
              });
            },
            items: ramStorageSizes.map((String size) {
              return DropdownMenuItem<String>(
                value: size,
                child: Text(size),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'RAM + Storage',
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedColor,
            onChanged: (value) {
              setState(() {
                selectedColor = value!;
              });
            },
            items: colors.map((String color) {
              return DropdownMenuItem<String>(
                value: color,
                child: Text(color),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Color',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // Perform submit action here
            // generate the following string format "Phone LTE/5G NR RAM+STORAGE (Hova) Color"
            var productstring = selectedPhoneModel! +
                " 5G " +
                selectedRamStorage! +
                "(HOV-AL00K) " +
                selectedColor!;
            String url = 'http://localhost:5000/buy/product';
            Map<String, String> headers = {
              'Content-Type': 'application/json',
            };

            Map<String, dynamic> requestBody = {
              'target': address.hex,
              'product_name': productstring,
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
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
