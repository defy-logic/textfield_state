import 'package:flutter/material.dart';
import 'package:textfield_state/textfield_state.dart';

/// Demo 1 - state only
class Demo1 extends StatefulWidget {
  @override
  _Demo1State createState() => _Demo1State();
}

class _Demo1State extends State<Demo1> {
  TextFieldState state;

  @override
  void initState() {
    state = TextFieldState(
      textChanged: _rebuild,
      focusChanged: _rebuild,
      primaryFocusChanged: _rebuild,
      text: 'Demo 1 - state only',
    );
    super.initState();
  }

  void _rebuild(_) => setState(() {});

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoTextField(state);
}

/// Demo 2 - widget defined
class Demo2 extends StatefulWidget {
  const Demo2(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  _Demo2State createState() => _Demo2State();
}

class _Demo2State extends State<Demo2> {
  TextFieldState state;

  @override
  void initState() {
    state = TextFieldState(
      textChanged: _rebuild,
      focusChanged: _rebuild,
      primaryFocusChanged: _rebuild,
      controller: widget.controller,
      focusNode: widget.focusNode,
    );
    super.initState();
  }

  void _rebuild(_) => setState(() {});

  @override
  void didUpdateWidget(Demo2 oldWidget) {
    state.update(controller: widget.controller, focusNode: widget.focusNode);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoTextField(state);
}

/// Demo 3 - text only
class Demo3 extends StatefulWidget {
  const Demo3(this.text);
  final String text;
  @override
  _Demo3State createState() => _Demo3State();
}

class _Demo3State extends State<Demo3> {
  TextFieldState state;

  @override
  void initState() {
    state = TextFieldState(
      textChanged: _rebuild,
      focusChanged: _rebuild,
      primaryFocusChanged: _rebuild,
      text: widget.text,
    );
    super.initState();
  }

  void _rebuild(_) => setState(() {});

  @override
  void didUpdateWidget(Demo3 oldWidget) {
    state.update(text: widget.text);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoTextField(state);
}

/// Helper for dumping info, shows connection to TextField.
class DemoTextField extends StatelessWidget {
  const DemoTextField(this.state);
  final TextFieldState state;
  @override
  Widget build(BuildContext context) => TextField(
        controller: state.controller,
        focusNode: state.focusNode,
        decoration: InputDecoration(
          helperText: 'focused: ${state.focusNode.hasFocus}, '
              'primary: ${state.focusNode.hasPrimaryFocus}\n'
              'text: ${state.controller.text}\n'
              'controller instance: ${state.controller.hashCode}\n'
              'focusNode instance: ${state.focusNode.hashCode}',
          helperMaxLines: 5,
        ),
      );
}

// ---

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// There's a Flutter issue when creating a FocusNode on every build.
  /// See https://stackoverflow.com/a/57586327/884522.
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TextFieldState Demo',
        theme: ThemeData(
          inputDecorationTheme:
              InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: Scaffold(
          appBar: AppBar(title: Text('TextFieldState Demo')),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(32),
              child: Column(
                children: <Widget>[
                  Demo1(),
                  SizedBox(height: 24),
                  Demo2(TextEditingController(text: 'Demo 2 - widget defined'), focusNode),
                  SizedBox(height: 24),
                  Demo3('Demo 3 - text only'),
                  SizedBox(height: 24),
                  RaisedButton(
                    child: Text('Rebuild'),
                    onPressed: () => setState(() {}),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
