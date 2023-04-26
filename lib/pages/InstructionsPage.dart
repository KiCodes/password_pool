import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import 'package:password_pool/main.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Texts.instructions),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: !appState.isDarkMode
                  ? [Colors.lightBlueAccent, Colors.blue]
                  : [Colors.black12, Colors.black45],
            )),
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: ListView(
            children: [
              _buildInstructionItem(
                  Texts.step1, Texts.step1_ins, context),
              _buildInstructionItem(
                  Texts.step2, Texts.step2_ins, context),
              _buildInstructionItem(
                  Texts.step3, Texts.step3_ins, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description, context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 2.5,
                decorationColor: Colors.white,
                color: Theme.of(context).colorScheme.inversePrimary)
          ),
          SizedBox(height: 8.0),
          Text(
            description,
            style: TextStyle(fontSize: 18.0,
            color: Theme.of(context).colorScheme.inverseSurface),
          ),
        ],
      ),
    );
  }
}
