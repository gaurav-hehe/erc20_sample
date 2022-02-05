// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mintAmount = TextEditingController();
  TextEditingController burnAmount = TextEditingController();

  @override
  void initState() {
    initialSetup();
    super.initState();
  }

  int balance = 0;
  int secAccBal = 0;
  int totalTokens = 0;

  late Client httpClient;
  late Web3Client ethClient;
  // JSON-RPC is a remote procedure call protocol encoded in JSON
  // Remote Procedure Call (RPC) is about executing a block of code on another server
  String rpcUrl = 'https://testnet.aurora.dev';

  Future<void> initialSetup() async {
    /// This will start a client that connects to a JSON RPC API, available at RPC URL.
    /// The httpClient will be used to send requests to the [RPC server].
    httpClient = Client();

    /// It connects to an Ethereum [node] to send transactions, interact with smart contracts, and much more!
    ethClient = Web3Client(rpcUrl, httpClient);

    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
  }

  /// This will construct [credentials] with the provided [privateKey]
  /// and load the Ethereum address in [myAdderess] specified by these credentials.

  //String acc1privateKey = '';
  //String acc2privateKey = '';

  late Credentials credentials1;
//TODO: insert primary and secondary acc public address
  var mainAddress = EthereumAddress.fromHex('0x...');
  var secondAccAdd = EthereumAddress.fromHex('0x...');

  Future<void> getCredentials() async {
    //TODO: insert private key
    credentials1 = await ethClient.credentialsFromPrivateKey('');
    //mainAddress = await credentials1.extractAddress();
  }

  /// This will parse an Ethereum address of the contract in [contractAddress]
  /// from the hexadecimal representation present inside the [ABI]
  late String abi;
  late EthereumAddress contractAddress;

  Future<void> getDeployedContract() async {
//TODO: insert abi file location
    String abiString = await rootBundle.loadString('abi.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson);
    //contractAddress = EthereumAddress.fromHex(abiJson['networks']['5777']['address']);

//TODO: insert contract address
    contractAddress =
        EthereumAddress.fromHex('0xD935E288b3C7905373aB8fEdAf849686029d38eb');
  }

  /// This will help us to find all the [public functions] defined by the [contract]
  late DeployedContract contract;
  late ContractFunction balanceOf, mint, burn, totalSupply;

  Future<void> getContractFunctions() async {
    contract = DeployedContract(
        ContractAbi.fromJson(abi, "SampleCoin"), contractAddress);

    balanceOf = contract.function('balanceOf');
    mint = contract.function('mint');
    burn = contract.function('burn');
    totalSupply = contract.function('totalSupply');
  }

  /// This will call a [functionName] with [functionArgs] as parameters
  /// defined in the [contract] and returns its result
  Future<List<dynamic>> readContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    var queryResult = await ethClient.call(
      contract: contract,
      function: functionName,
      params: functionArgs,
    );

    return queryResult;
  }

  /// Signs the given transaction using the keys supplied in the [credentials] object
  /// to upload it to the client so that it can be executed
  Future<void> writeContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    await ethClient.sendTransaction(
      credentials1,
      Transaction.callContract(
        contract: contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Main Acc Balance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$balance',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var result =
                                await readContract(balanceOf, [mainAddress]);
                            balance = result.first.toInt();
                            setState(() {});
                            print('Button pressed...');
                          },
                          child: const Text('Get Balance'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Add to Main Acc',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'amount',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print('Button pressed...');
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Transfer to Acc 2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'amount',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print('Button pressed...');
                          },
                          child: const Text('Transfer'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Acc 2 Balance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$secAccBal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var result =
                                await readContract(balanceOf, [secondAccAdd]);
                            secAccBal = result.first.toInt();
                            setState(() {});
                            print('Button pressed...');
                          },
                          child: const Text('Get Balance'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Total Supply',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$totalTokens',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var result = await readContract(totalSupply, []);
                            totalTokens = result.first.toInt();
                            setState(() {});
                            print('Button pressed...');
                          },
                          child: const Text('Get Supply'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Mint Tokens',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          controller: mintAmount,
                          decoration: const InputDecoration(
                            hintText: 'amount',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await writeContract(mint,
                                [mainAddress, BigInt.parse(mintAmount.text)]);
                            setState(() {});
                            print('Button pressed...');
                          },
                          child: const Text('Mint'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.19,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      border: Border.all(
                        color: const Color(0xFF191919),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Burn Tokens',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          controller: burnAmount,
                          decoration: const InputDecoration(
                            hintText: 'amount',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await writeContract(burn,
                                [mainAddress, BigInt.parse(burnAmount.text)]);
                            setState(() {});
                            print('Button pressed...');
                          },
                          child: const Text('Burn'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
