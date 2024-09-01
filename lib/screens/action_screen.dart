import 'package:cstain/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../backend/auth_gate.dart';
import '../models/user_contribution.dart';
import 'action_detailScreen.dart';

class ActionScreen extends ConsumerStatefulWidget {
  @override
  _ActionScreenState createState() => _ActionScreenState();
}

class _ActionScreenState extends ConsumerState<ActionScreen> {
  List<UserContributionModel> todayActions = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayActions();
  }

  Future<void> _fetchTodayActions() async {
    final myUser = ref.read(userProvider);

    if (myUser != null) {
      final firestoreService = ref.read(firestoreServiceProvider);
      final actions =
          await firestoreService.fetchTodayUserContributions(myUser.uid);
      setState(() {
        todayActions = actions;
      });
    }
  }

  String _formatDuration(double hours) {
    return '${hours.toStringAsFixed(2)} hours';
  }

  @override
  Widget build(BuildContext context) {
    final myUser = ref.watch(userProvider);
    final totalCarbonSaved = _calculateTotalCarbonSaved();
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Actions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total Carbon Saved Today',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${totalCarbonSaved.toStringAsFixed(2)} kg',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todayActions.length,
              itemBuilder: (context, index) {
                final action = todayActions[index];
                return ListTile(
                  title: Text(action.action),
                  subtitle: Text(
                      '${_formatDuration(action.duration)} - ${action.category}'),
                  trailing: Text(
                      'CO2 saved: ${action.co2_saved.toStringAsFixed(2)} kg'),
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
                onAddLog: (String log) {
                  // This function is not used anymore, but kept for compatibility
                },
                userId: myUser!.uid,
                onNavigateBack: () {
                  _fetchTodayActions(); // Refresh the list when returning from ActionDetailScreen
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  double _calculateTotalCarbonSaved() {
    return todayActions.fold(0.0, (sum, action) => sum + action.co2_saved);
  }
}
