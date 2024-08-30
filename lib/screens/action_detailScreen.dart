import 'package:cstain/components/loader.dart';
import 'package:cstain/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/duration_picker.dart';

class ActionDetailScreen extends ConsumerWidget {
  final Function(String) onAddLog;
  final String userId;

  ActionDetailScreen({required this.onAddLog, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Action Details'),
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          return Column(
            children: [
              SizedBox(height: 20),
              Text('Which Action do you want to log?',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return ChoiceChip(
                      label: Text(category.category_name),
                      selected:
                          false, // You might want to manage selected state
                      onSelected: (selected) {
                        // Handle category selection
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text('How did you reduce emissions?',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: ['Carpool', 'Bike', 'Train'].map((method) {
                    return ListTile(
                      title: Text(method),
                      onTap: () {
                        _showBottomSheet(context, method);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => Loader(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String method) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Duration selectedDuration = Duration();

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the duration for $method'),
                  SizedBox(height: 10),
                  CustomDurationPicker(
                    initialDuration: selectedDuration,
                    onDurationChanged: (newDuration) {
                      setState(() {
                        selectedDuration = newDuration;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final hours = selectedDuration.inHours;
                      final minutes = selectedDuration.inMinutes % 60;
                      final formattedDuration = '${hours}h ${minutes}m';

                      onAddLog('$method for $formattedDuration');
                      Navigator.pop(context);
                    },
                    child: Text('Add Log'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
