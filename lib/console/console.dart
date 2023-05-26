import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:libserialport/libserialport.dart';

class ListConsole extends StatefulWidget {
  final SerialPort? port;

  const ListConsole({required this.port, super.key});

  @override
  ListConsoleState createState() {
    return ListConsoleState();
  }
}

class ListConsoleState extends State<ListConsole> {
  final List<String> _consoleLines = [];

  StreamSubscription _consoleStreamSubscription =
      const Stream.empty().listen((event) {});
  final ScrollController _scroll = ScrollController();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNodePrompt = FocusNode(debugLabel: "ConsolePrompt");
  final FocusNode _focusNodeConsoleOut = FocusNode(debugLabel: "ConsoleOutput");

  @override
  void initState() {
    super.initState();
    _setSourceStream();
  }

  @override
  void didUpdateWidget(covariant ListConsole oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.port != widget.port) {
      _setSourceStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // TODO: idea keyboardlistener should redirect focus to textfield below. Issue: sometimes the keyboard listener does not get focus, despite being clicked. Redirect does not work.
          child: KeyboardListener(
            focusNode: _focusNodeConsoleOut,
            autofocus: true,
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                print(event.character);
                _focusNodePrompt.requestFocus();
              }
            },
            child: SelectionArea(
              child: ListView.builder(
                prototypeItem: const Text(
                    "dummy"), //itemBuilder(context, 0), //TODO factor out item build method to allow creating a dummy item with an empty list => make that actually class widget
                itemBuilder: itemBuilder,
                itemCount: _consoleLines.length,
                // physics: const PageScrollPhysics(),
                controller: _scroll,
              ),
            ),
          ),
        ),
        TextField(
          autofocus: true,
          controller: _textController,
          focusNode: _focusNodePrompt,
          onSubmitted: (value) {
            print(value);
            value += "\n";
            widget.port?.write(Uint8List.fromList(value.codeUnits));
            _textController.clear();
            _focusNodePrompt.requestFocus();
          },
        ),
      ],
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    return Text(_consoleLines[index]);
  }

  void _setSourceStream() {
    _consoleStreamSubscription.cancel();
    // TODO: this could leak console lines, i.e. if we switch to a tab with a different console. Make sure that the events are buffered. (Have a permanent isolate adding to list and use that? (+an set state if the isolate modifies the list))
    // TODO: handle errors done cancel on error
    //StreamSubscription<T> listen(void Function(T event)? onData,
    //    {Function? onError, void Function()? onDone, bool? cancelOnError});

    Stream stream = const Stream.empty();
    if (widget.port != null) {
      SerialPortReader reader = SerialPortReader(widget.port!);
      stream = reader.stream
          .map((asciiValue) => String.fromCharCodes(asciiValue))
          .transform(const LineSplitter());
    }

    _consoleStreamSubscription = stream.listen((line) {
      setState(() {
        _consoleLines.add(line);
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _consoleStreamSubscription.cancel();
    _focusNodeConsoleOut.dispose();
    _focusNodePrompt.dispose();
  }
}
