import 'package:cstain/models/corp_user.dart';
import 'package:cstain/providers/corp_user_provider.dart';
import 'package:cstain/screens/Corp%20screens/corp_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CorpUserFormScreen extends ConsumerStatefulWidget {
  final String userId;
  const CorpUserFormScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CorpUserFormScreenState createState() => _CorpUserFormScreenState();
}

class _CorpUserFormScreenState extends ConsumerState<CorpUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController goalController = TextEditingController();

  String? selectedType;
  String? selectedSize;
  final List<String> companyTypes = [
    "Agriculture",
    "Manufacturing",
    "Healthcare",
    "Transportation and Logistics",
    "Real Estate",
    "Energy Management",
    "Educational Services",
    "Finance and Insurance",
    "Electronics",
    "Food Manufacturing",
    "IT and IT Services",
    "Others"
  ];

  final List<String> companySizes = [
    "Less than 50",
    "51 - 200",
    "201 - 500",
    "501 - 1000",
    "1001 - 5000",
    "5001 - 10000",
    "More than 10000"
  ];

  Future<void> saveCorpUser() async {
    if (_formKey.currentState!.validate()) {
      final corpUser = CorpUserModel(
        userId: widget.userId,
        name: nameController.text,
        type: selectedType!,
        size: selectedSize!,
        goal: goalController.text,
      );

      await ref.read(corpUserRepositoryProvider).saveCorpUser(corpUser);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CorpBottomNav()),
      );
    }
  }

  void skipForm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CorpBottomNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Corporate Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Company Name",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter company name" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: companyTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => selectedType = value),
                decoration: InputDecoration(
                  labelText: "Company Type",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) =>
                    value == null ? "Select a company type" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSize,
                items: companySizes.map((size) {
                  return DropdownMenuItem(value: size, child: Text(size));
                }).toList(),
                onChanged: (value) => setState(() => selectedSize = value),
                decoration: InputDecoration(
                  labelText: "Company Size",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) =>
                    value == null ? "Select a company size" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: goalController,
                decoration: InputDecoration(
                  labelText: "Your Motive",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) => value == null ? "Write a motive" : null,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: saveCorpUser,
                    child: Text("Submit"),
                  ),
                  TextButton(
                    onPressed: skipForm,
                    child: Text(
                      "Do It Later",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
