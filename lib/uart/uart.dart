import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class UartSettings {
  String? port = SerialPort.availablePorts.firstOrNull;
}

class UartControls extends InheritedWidget {
  final UartSettings uartSettings = UartSettings();

  UartControls({super.key, required super.child});

  @override
  bool updateShouldNotify(UartControls oldWidget) {
    return false;
  }

  static UartControls? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<UartControls>();
  }

  static UartControls of(BuildContext context) {
    UartControls? controls = maybeOf(context);
    assert(controls != null, 'No UartControls found in context');
    return controls!;
  }
}

class PortPicker extends StatefulWidget {
  const PortPicker({super.key});

  @override
  PortPickerState createState() {
    return PortPickerState();
  }
}

class PortPickerState extends State<PortPicker> {
  //String? _selectedItem = SerialPort.availablePorts.firstOrNull;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: UartControls.of(context).uartSettings.port,
      items:
          SerialPort.availablePorts.map<DropdownMenuItem<String>>((portName) {
        SerialPort port = SerialPort(portName);
        return DropdownMenuItem<String>(
          value: portName,
          child: Text("$portName [${port.manufacturer}::${port.productName}]"),
        );
      }).toList(),
      onChanged: (port) {
        setState(() {
          UartControls.of(context).uartSettings.port = port;
        });
      },
    );
  }
}

SerialPort openUartPort(String comPortName) {
  SerialPort port = SerialPort(comPortName);
  // port.openReadWrite(); // TODO: errorcheck

  if (!port.openReadWrite()) {
    print(SerialPort.lastError);
    exit(-1);
  }

  // port.

  SerialPortConfig portConfig = port.config; //(); // TODO
  portConfig
    ..baudRate = 115200
    ..bits = 8
    //..cts = SerialPortCts.ignore;
    //..dsr = SerialPortDsr.ignore;
    //..dtr = SerialPortDtr.off;
    ..parity = SerialPortParity.none
    // ..rts = SerialPortRts.off;
    ..stopBits = 1;
  //..xonXoff = SerialPortXonXoff.disabled;

  // +flow UTF-8 {RTS (CTS) DTR !DSR (!CD)} 0(ttyUSB0)
  // ..setFlowControl(SerialPortFlowControl.xonXoff);

  port.config = portConfig;
  // TODO? portConfig.dispose();

  return port;

  // SerialPortReader reader = SerialPortReader(
  //     port); //TODO: can we use the reader or do we have ot implement our own to intermix send/receive.

  // return reader.stream;
}
