import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/providers/action%20providers/providers.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../backend/auth_gate.dart';
import '../../models/user_contribution.dart';
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
    //countUserContributions();
  }

  //firestore service

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

  String _formatDuration(double value, String category) {
    if (category.toLowerCase() == 'food') {
      return '${value.toInt()} meals';
    } else {
      return '${value.toStringAsFixed(2)} hrs';
    }
  }

  // Map categories to specific icons and colors
  Map<String, dynamic> _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return {
          'icon': Icons.restaurant,
          'color': Colors.orange[400],
        };
      case 'electricity':
        return {
          'icon': Icons.bolt,
          'color': Colors.red,
        };
      case 'vehicle':
        return {
          'icon': Icons.directions_car,
          'color': Colors.blue,
        };
      default:
        return {
          'icon': Icons.eco,
          'color': Colors.green,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUser = ref.watch(userProvider);
    final totalCarbonSaved = _calculateTotalCarbonSaved();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Actions',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        leading: Image.asset('assets/Earth black 1.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      })
                    ],
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/Earth black 1.png'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCarbonSavedCard(context, totalCarbonSaved),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Today's Actions",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Color(0xFF5F5F5F),
                    ),
              ),
            ),
            SizedBox(height: 8),
            _buildActionsList(), // This is wrapped inside a SingleChildScrollView now
          ],
        ),
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
        backgroundColor: const Color.fromARGB(255, 205, 246, 230),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }

  Widget _buildTotalCarbonSavedCard(
      BuildContext context, double totalCarbonSaved) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Today\'s Carbon Saving',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[800], fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    '${totalCarbonSaved.toStringAsFixed(2)} kg',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Color(0xFF237155),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: todayActions.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300],
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final action = todayActions[index];
        final categoryData = _getCategoryIcon(action.category);

        return Dismissible(
          key: Key(action.contribution_id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _deleteAction(action);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: categoryData['color'],
              child: Icon(
                categoryData['icon'], // Use category-specific icon
                color: Colors.white,
              ),
            ),
            title: Text(
              action.action,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            subtitle: Text(
              '${_formatDuration(action.duration, action.category)} - ${action.category}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            trailing: Text(
              '${action.co2_saved.toStringAsFixed(2)} kg',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Color(0xFF237155), // CO2 saved text color updated
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Removed the shape property to remove the border
        );
      },
    );
  }

  double _calculateTotalCarbonSaved() {
    return todayActions.fold(0.0, (sum, action) => sum + action.co2_saved);
  }

  Future<void> _deleteAction(UserContributionModel action) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteUserContribution(action);

      setState(() {
        todayActions.remove(action);
      });

      // Update the total carbon saved
      final totalCarbonSaved = _calculateTotalCarbonSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action deleted successfully')),
      );
    } catch (e) {
      print('Error deleting action: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete action')),
      );
    }
  }
}
// //*******************just tried with the action providers************************* */
// import 'package:cstain/providers/actions_provider.dart';
// import 'package:cstain/screens/action_detailScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user_contribution.dart';
// import '../providers/auth_service.dart';

// class ActionScreen extends ConsumerStatefulWidget {
//   const ActionScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ActionScreen> createState() => _ActionScreenState();
// }

// class _ActionScreenState extends ConsumerState<ActionScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final myUser = ref.watch(userProvider);
//     final todayActionsAsync = ref.watch(todayActionsProvider);

//     final totalCarbonSaved = todayActionsAsync.when(
//       data: (actions) =>
//           actions.fold(0.0, (sum, action) => sum + action.co2_saved),
//       loading: () => 0.0,
//       error: (_, __) => 0.0,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Actions', style: TextStyle(fontWeight: FontWeight.w400)),
//       ),
//       body: Column(
//         children: [
//           _buildTotalCarbonSavedCard(context, totalCarbonSaved),
//           Expanded(
//             child: todayActionsAsync.when(
//               data: (actions) => actions.isEmpty
//                   ? _buildNoActionsPlaceholder()
//                   : _buildActionsList(actions),
//               loading: () => Center(child: CircularProgressIndicator()),
//               error: (error, stack) =>
//                   Center(child: Text('Error loading actions')),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ActionDetailScreen(
//                 userId: myUser!.uid,
//                 onNavigateBack: () {
//                   ref.invalidate(
//                       todayActionsProvider); // Refresh list after returning
//                 },
//                 onAddLog: (String) {},
//               ),
//             ),
//           );
//         },
//         icon: Icon(Icons.add),
//         label: Text("New Action"),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   Widget _buildTotalCarbonSavedCard(
//       BuildContext context, double totalCarbonSaved) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Total Carbon Saved Today",
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text(
//                 '${totalCarbonSaved.toStringAsFixed(2)} kg CO₂',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: Color(0xFF237155), fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionsList(List<UserContributionModel> actions) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: BouncingScrollPhysics(),
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       itemCount: actions.length,
//       separatorBuilder: (context, index) =>
//           Divider(color: Colors.grey[300], thickness: 1),
//       itemBuilder: (context, index) {
//         final action = actions[index];
//         final categoryData = _getCategoryIcon(action.category);
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: categoryData['color'],
//             child: Icon(categoryData['icon'], color: Colors.white),
//           ),
//           title: Text(
//             action.action,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//           ),
//           subtitle: Text(
//             '${_formatDuration(action.duration.toInt(), action.category)} - ${action.category}',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey[600],
//                 ),
//           ),
//           trailing: Text(
//             '${action.co2_saved.toStringAsFixed(2)} kg',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color: Color(0xFF237155),
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNoActionsPlaceholder() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.hourglass_empty, size: 50, color: Colors.grey),
//             SizedBox(height: 8),
//             Text(
//               "No actions recorded today!",
//               style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic> _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Transport':
//         return {'icon': Icons.directions_car, 'color': Colors.blue};
//       case 'Energy':
//         return {'icon': Icons.flash_on, 'color': Colors.orange};
//       case 'Food':
//         return {'icon': Icons.restaurant, 'color': Colors.green};
//       default:
//         return {'icon': Icons.category, 'color': Colors.grey};
//     }
//   }

//   String _formatDuration(int duration, String category) {
//     if (category == 'Transport') {
//       return '$duration min';
//     } else if (category == 'Energy') {
//       return '$duration kWh';
//     } else {
//       return '$duration items';
//     }
//   }
// }
