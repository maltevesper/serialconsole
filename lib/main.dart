import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import 'package:serial_console/console/console.dart';
import 'package:serial_console/uart/uart.dart';

Stream<String> dummyStream() async* {
  int i = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield "message no $i.";
    i = i + 2;
  }
}

/*
 * Architecture:
 * 
 * RS232 Stream -> Streamsplitter (dart async package, caches the stream and allows to create new streams from it) -> Filter Stream (chainable, i.e. different filters can be combined, do I need StreamCOntrolller to implement this?) -> ListView (aka console)
 */

void main() async {
  runApp(const SerialConsole());
}

class SerialConsole extends StatefulWidget {
  const SerialConsole({super.key});

  @override
  SerialConsoleState createState() {
    return SerialConsoleState();
  }
}

class SerialConsoleState extends State<SerialConsole> {
  SerialPort? _port;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Source Code Pro"),
      home: Scaffold(
        body: Column(children: [
          UartControls(
            child: Row(
              children: [
                const PortPicker(),
                ConnectButton(callback: updatePort),
              ],
            ),
          ),
          Expanded(
            child: ListConsole(port: _port),
          ),
        ]),
      ),
    );
  }

  void updatePort(String portname) {
    setState(() {
      _port = openUartPort(portname);
    });
  }
}

// A hole lot of mess, just so the onPressed closure has UartControls in its context.
class ConnectButton extends StatelessWidget {
  final void Function(String) callback;

  const ConnectButton({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          //setState(() {
          String? portname = UartControls.of(context).uartSettings.port;
          if (portname != null) {
            //  _port = openUartPort(portname);
            callback(portname);
          }
          // });
        },
        icon: const Icon(Icons.play_arrow));
  }
}
