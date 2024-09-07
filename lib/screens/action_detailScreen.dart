import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/components/duration_picker.dart';
import 'package:cstain/components/loader.dart';
import 'package:cstain/components/streak_service.dart';
import 'package:cstain/models/categories_and_action.dart';
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

    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Color(0xFF5F5F5F),
          fontSize: 14,
        );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onNavigateBack,
        ),
        title: Text(
          'Action Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true, // Center the title
        elevation: 0, // Remove the shadow
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Which Action do you want to log?',
                  style: textStyle,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: uniqueCategories.map((categoryName) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(
                            categoryName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          selected: selectedCategory == categoryName,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = selected ? categoryName : null;
                              selectedAction = null;
                            });
                          },
                          selectedColor: const Color.fromARGB(255, 1, 163, 119),
                          backgroundColor:
                              const Color.fromARGB(159, 237, 239, 238),
                          labelStyle: TextStyle(
                            color: selectedCategory == categoryName
                                ? Colors.white
                                : Colors.black,
                          ),
                          shape: StadiumBorder(), // Rounded chip
                          checkmarkColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (selectedCategory != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Actions for $selectedCategory:',
                    style: textStyle?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: actionsForSelectedCategory.length,
                      itemBuilder: (context, index) {
                        final action = actionsForSelectedCategory[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 0, // Flat design, no shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            leading:
                                Icon(Icons.add, color: const Color(0xFF237155)),
                            title: Text(
                              action,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            horizontalTitleGap: 8.0,
                            onTap: () {
                              setState(() {
                                selectedAction = action;
                              });
                              _showBottomSheet(context, action);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => Loader(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String action) {
    if (selectedCategory == 'Food') {
      _showFoodInputBottomSheet(context, action);
    } else {
      _showDurationInputBottomSheet(context, action);
    }
  }

  void _showFoodInputBottomSheet(BuildContext context, String action) {
    int numberOfMeals = 1;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the number of meals for $action',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Color(0xFF5F5F5F),
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (numberOfMeals > 1) numberOfMeals--;
                          });
                        },
                      ),
                      Text(
                        numberOfMeals.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            numberOfMeals++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final categories = ref.read(categoriesProvider).value;
                        final actionModel = categories?.firstWhere(
                          (cat) => cat.action_name == action,
                          orElse: () => CategoriesAndActionModel(
                              action_name: action, co2_saving_factor: 0),
                        );
                        final co2SavingFactor =
                            actionModel?.co2_saving_factor ?? 0;

                        final contribution = UserContributionModel(
                          contribution_id: Uuid().v4(),
                          action: action,
                          category: selectedCategory!,
                          co2_saved: numberOfMeals * co2SavingFactor,
                          created_at: Timestamp.now(),
                          duration: numberOfMeals.toDouble(),
                          user_id: widget.userId,
                        );

                        try {
                          final firestoreService =
                              ref.read(firestoreServiceProvider);
                          await firestoreService
                              .addUserContribution(contribution);
                          print('User contribution added successfully');

                          widget.onAddLog(
                              '$action: $numberOfMeals meals, CO2 saved: ${(numberOfMeals * co2SavingFactor).toStringAsFixed(2)}');
                          Navigator.pop(context);
                          widget.onNavigateBack();
                        } catch (e) {
                          print('Error adding user contribution: $e');
                        }
                      },
                      child: Text('Add Log'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF237155),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDurationInputBottomSheet(BuildContext context, String action) {
    Duration selectedDuration = Duration.zero;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the duration for $action',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(0xFF5F5F5F),
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 16),
              CustomDurationPicker(
                initialDuration: selectedDuration,
                onDurationChanged: (newDuration) {
                  setState(() {
                    selectedDuration = newDuration;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final categories = ref.read(categoriesProvider).value;
                    final actionModel = categories?.firstWhere(
                      (cat) => cat.action_name == action,
                      orElse: () => CategoriesAndActionModel(
                          action_name: action, co2_saving_factor: 0),
                    );
                    final co2SavingFactor = actionModel?.co2_saving_factor ?? 0;

                    final contribution = UserContributionModel(
                      contribution_id: Uuid().v4(),
                      action: action,
                      category: selectedCategory!,
                      co2_saved: selectedDuration.inMinutes * co2SavingFactor,
                      created_at: Timestamp.now(),
                      duration: selectedDuration.inMinutes.toDouble(),
                      user_id: widget.userId,
                    );

                    try {
                      final firestoreService =
                          ref.read(firestoreServiceProvider);
                      await firestoreService.addUserContribution(contribution);
                      print('User contribution added successfully');

                      widget.onAddLog(
                          '$action: ${selectedDuration.inMinutes} minutes, CO2 saved: ${(selectedDuration.inMinutes * co2SavingFactor).toStringAsFixed(2)}');
                      Navigator.pop(context);
                      widget.onNavigateBack();
                      logUserAction();
                    } catch (e) {
                      print('Error adding user contribution: $e');
                    }
                  },
                  child: Text('Add Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF237155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
