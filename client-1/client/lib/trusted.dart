library client.trusted;

// Trusted Firms
final trusted = {
  "0x0000000000000000000000000000000000000000": "Root",
  "0x1ea8Ed0363F1d03C7907cE8D299823Fa3FAa4887".toLowerCase():
      "ABC Technologies Ltd."
};
bool checkIfTrusted(String address) {
  if (trusted.containsKey(address.toLowerCase())) {
    return true;
  } else {
    return false;
  }
}

String? getFirmName(String address) {
  if (trusted.containsKey(address)) {
    return trusted[address];
  } else {
    return address;
  }
}
