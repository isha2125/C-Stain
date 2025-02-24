import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/providers/campaign%20providers/campaign_repository.dart';
import 'package:cstain/providers/action%20providers/providers.dart';
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
