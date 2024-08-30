import 'package:cstain/screens/action_detailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../backend/auth_gate.dart';

class ActionScreen extends ConsumerStatefulWidget {
  @override
  _ActionScreenState createState() => _ActionScreenState();
}

class _ActionScreenState extends ConsumerState<ActionScreen> {
  List<String> loggedActions = [];

  void _addLog(String log) {
    setState(() {
      loggedActions.add(log);
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUser = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Actions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: loggedActions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(loggedActions[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActionDetailScreen(
                onAddLog: _addLog,
                userId: myUser!.uid,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
