# server.py
from flask import Flask, jsonify, request
from web3 import Web3
import json
import uuid
app = Flask(__name__)
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:7545'))
abi = ""
addr = "0x1ea8Ed0363F1d03C7907cE8D299823Fa3FAa4887"
privkey = "0x6d7198420b73ca72d571b7c162cc3b8cd0c41f58f24cfc4f7f6c46d4f7abfaeb"
bytecode = ""
with open("../build/contracts/Receipt.json",encoding="UTF8") as f:
    data = json.loads(f.read())
    abi = data["abi"]
    bytecode = data["bytecode"]
@app.route('/buy/product', methods=['POST'])
def buy_product():
    target = Web3.to_checksum_address(request.json['target'])
    # get product name
    product_name = request.json['product_name']
    #product_name = "HUAWEI P50 PRO 5G (JAD-AN00) 12+256GB Golden Special Edition"
    sn = uuid.uuid4().hex
    Contract = w3.eth.contract(abi=abi,bytecode=bytecode)
    # CREATE THE CONTRACT
    deploy_txn = Contract.constructor(target,product_name,sn,12).build_transaction({'nonce':w3.eth.get_transaction_count(addr)})
    signed_txn = w3.eth.account.sign_transaction(deploy_txn, private_key=privkey)
    tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    contract_address = tx_receipt['contractAddress']
    return "OK!"
@app.route('/buy/warranty', methods=['POST'])
def buy_warranty():
    target = Web3.to_checksum_address(request.json['contractaddr'])
    print(target)
    # get product name
    months = int(request.json['months'])
    contract = w3.eth.contract(address=target, abi=abi)
    tx_hash = contract.functions.updateWarranty(months).transact({'from':addr})
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    # Sign the transaction
    #signed_transaction = w3.eth.account.sign_transaction(transaction, private_key=privkey)

    # Send the transaction
    #transaction_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)

    # Wait for the transaction to be mined
    return "OK!"
if __name__ == '__main__':
    app.run(debug=True)