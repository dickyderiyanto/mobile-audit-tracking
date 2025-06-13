import 'package:flutter/material.dart';

class SynchronizeView extends StatefulWidget {
  const SynchronizeView({super.key});

  @override
  State<SynchronizeView> createState() => _SynchronizeViewState();
}

class _SynchronizeViewState extends State<SynchronizeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), actions: const []),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: []),
      ),
    );
  }
}
