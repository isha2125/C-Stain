// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class CreateCampaignForm extends StatefulWidget {
//   @override
//   State<CreateCampaignForm> createState() => _CreateCampaignFormState();
// }

// class _CreateCampaignFormState extends State<CreateCampaignForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _actionController = TextEditingController();
//   final _targetCO2SavingsController = TextEditingController();

//   DateTime? _startDate;
//   DateTime? _endDate;

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = pickedDate;
//         } else {
//           _endDate = pickedDate;
//         }
//       });
//     }
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       final newCampaign = {
//         'title': _titleController.text,
//         'description': _descriptionController.text,
//         'category': _categoryController.text,
//         'action': _actionController.text,
//         'targetCO2Savings':
//             double.parse(_targetCO2SavingsController.text.trim()),
//         'startDate': _startDate ?? DateTime.now(),
//         'endDate': _endDate ?? DateTime.now(),
//         'createdAt': DateTime.now(),
//       };

//       Navigator.pop(context, newCampaign);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Campaign'),
//         backgroundColor: const Color(0xFF237155),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Campaign Title',
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 4,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _categoryController,
//                 decoration: const InputDecoration(
//                   labelText: 'Category',
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _actionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Action',
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _targetCO2SavingsController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Target CO2 Savings (in tons)',
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         labelText: 'Start Date',
//                         hintText: _startDate != null
//                             ? DateFormat('yyyy-MM-dd').format(_startDate!)
//                             : 'Select Start Date',
//                         filled: true,
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(12)),
//                         ),
//                       ),
//                       onTap: () => _selectDate(context, true),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         labelText: 'End Date',
//                         hintText: _endDate != null
//                             ? DateFormat('yyyy-MM-dd').format(_endDate!)
//                             : 'Select End Date',
//                         filled: true,
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(12)),
//                         ),
//                       ),
//                       onTap: () => _selectDate(context, false),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF237155),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('Add Campaign'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//******************************************with backen code is below */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/providers/campaign_repository.dart';
import 'package:cstain/providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // For generating unique campaignId

class CreateCampaignForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends ConsumerState<CreateCampaignForm> {
  String? selectedCategory;
  String? selectedAction;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in.')),
        );
        return;
      }

      _formData['corpUserId'] = currentUser.uid;
      _formData['created_at'] = Timestamp.now();
      _formData['campaignId'] =
          FirebaseFirestore.instance.collection('campaigns').doc().id;

      try {
        await ref.read(campaignProvider.notifier).addCampaign(_formData);
        Navigator.pop(context, _formData);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create campaign: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Campaigns',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
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
        // automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _formData['title'] = value,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            // Description field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _formData['description'] = value,
              validator: (value) => value == null || value.isEmpty
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 16),
            // Category field
            categoriesAsyncValue.when(
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
                    .where((category) =>
                        category.category_name == selectedCategory)
                    .map((category) => category.action_name)
                    .where((action) => action != null)
                    .cast<String>()
                    .toList();

                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: uniqueCategories
                          .map((categoryName) => DropdownMenuItem<String>(
                                value: categoryName,
                                child: Text(categoryName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          selectedAction =
                              null; // Reset action when category changes
                        });
                      },
                      onSaved: (value) =>
                          _formData['category'] = value, // Add this line
                      validator: (value) => value == null || value.isEmpty
                          ? 'Category is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (selectedCategory != null)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Action',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedAction,
                        items: actionsForSelectedCategory
                            .map((actionName) => DropdownMenuItem<String>(
                                  value: actionName,
                                  child: Text(actionName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAction = value;
                            _formData['action'] = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Action is required'
                            : null,
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            const SizedBox(height: 16),
            // Target CO2 Savings field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Target CO2 Savings (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) =>
                  _formData['targetCO2Savings'] = double.tryParse(value ?? '0'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Target CO2 Savings is required'
                  : null,
            ),
            const SizedBox(height: 16),
            // Start Date field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _formData['startDate'] ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _formData['startDate'] = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                text: _formData['startDate'] != null
                    ? DateFormat('yyyy-MM-dd').format(_formData['startDate'])
                    : '',
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Start Date is required'
                  : null,
            ),
            const SizedBox(height: 16),
            // End Date field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _formData['endDate'] ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _formData['endDate'] = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                text: _formData['endDate'] != null
                    ? DateFormat('yyyy-MM-dd').format(_formData['endDate'])
                    : '',
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'End Date is required'
                  : null,
            ),
            const SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF237155),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Campaign',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
