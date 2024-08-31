import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/components/duration_picker.dart';
import 'package:cstain/components/loader.dart';
import 'package:cstain/models/user_contribution.dart';
import 'package:cstain/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ActionDetailScreen extends ConsumerStatefulWidget {
  final Function(String) onAddLog;
  final String userId;
  final VoidCallback onNavigateBack;

  ActionDetailScreen({
    required this.onAddLog,
    required this.userId,
    required this.onNavigateBack,
  });

  @override
  _ActionDetailScreenState createState() => _ActionDetailScreenState();
}

class _ActionDetailScreenState extends ConsumerState<ActionDetailScreen> {
  String? selectedCategory;
  String? selectedAction;

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Action Details'),
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          final uniqueCategories = categories
              .where((category) =>
                  category.category_name != null &&
                  category.category_name!.isNotEmpty &&
                  category.category_name!.toLowerCase() != 'unknown')
              .map((category) => category.category_name!)
              .toSet()
              .toList();

          final actionsForSelectedCategory = categories
              .where((category) => category.category_name == selectedCategory)
              .map((category) => category.action_name)
              .where((action) => action != null)
              .cast<String>()
              .toList();

          return Column(
            children: [
              const SizedBox(height: 20),
              const Text('Which Action do you want to log?',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: uniqueCategories.map((categoryName) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(categoryName),
                        selected: selectedCategory == categoryName,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? categoryName : null;
                            selectedAction = null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (selectedCategory != null) ...[
                SizedBox(height: 20),
                Text('Actions for ${selectedCategory}:',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: actionsForSelectedCategory.length,
                    itemBuilder: (context, index) {
                      final action = actionsForSelectedCategory[index];
                      return ListTile(
                        title: Text(action),
                        onTap: () {
                          setState(() {
                            selectedAction = action;
                          });
                          _showBottomSheet(context, action);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => Loader(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String action) {
    Duration selectedDuration = Duration();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the duration for $action'),
                  SizedBox(height: 10),
                  CustomDurationPicker(
                    initialDuration: selectedDuration,
                    onDurationChanged: (newDuration) {
                      selectedDuration = newDuration;
                      setState(
                          () {}); // Trigger a rebuild of the StatefulBuilder
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final hours = selectedDuration.inHours;
                      final minutes = selectedDuration.inMinutes % 60;
                      final formattedDuration = '${hours}h ${minutes}m';
                      final contribution = UserContributionModel(
                        contribution_id: Uuid().v4(),
                        action: action,
                        category: selectedCategory!,
                        co2_saved:
                            0, // You'll need to calculate this based on the action
                        created_at: Timestamp.now(),
                        duration: selectedDuration.inMinutes,
                        user_id: widget.userId,
                        // Or set as needed
                      );

                      // Use the provider to get FirestoreService instance and add the user contribution
                      try {
                        final firestoreService =
                            ref.read(firestoreServiceProvider);
                        await firestoreService
                            .addUserContribution(contribution);
                        print('User contribution added successfully');
                      } catch (e) {
                        print('Error adding user contribution: $e');
                        // Handle the error (e.g., show an error message to the user)
                      }

                      widget.onAddLog('$action for $formattedDuration');
                      Navigator.pop(context);

                      widget.onNavigateBack();
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
