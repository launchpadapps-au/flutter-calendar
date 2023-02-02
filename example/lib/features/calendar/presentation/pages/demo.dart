import 'package:flutter/material.dart';
/// demo
class Demo extends StatefulWidget {
  ///initialize demo
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Hiii')),
      body: ListView.builder(
 
        itemBuilder: (BuildContext context, int index) => SizedBox(
          width: size.width,
          height: size.height,
          child: Center(
            child: Text('$index'),
          ),
        ),
      ),
    );
  }
}
