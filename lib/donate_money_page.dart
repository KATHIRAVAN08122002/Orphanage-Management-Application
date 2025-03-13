import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class DonateMoneyPage extends StatefulWidget {
  final String title;

  DonateMoneyPage({required this.title});

  @override
  _DonateMoneyPageState createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _orphanageTitleController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _orphanageTitleController.text = widget.title;
  }

  Future<void> _fetchUserData() async {
    userId = await FirestoreService().getUserId();
    if (userId != null) {
      var userData = await FirestoreService().getUserData(userId!);
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _mobileController.text = userData['phone'] ?? '';
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && userId != null) {
      Timestamp currentTimestamp = Timestamp.now();

      final donationData = {
        'orphanage': _orphanageTitleController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'mobile': _mobileController.text,
        'amount': double.parse(_amountController.text),
        'transactionId': _transactionIdController.text,
        'timestamp': currentTimestamp,
      };

      await FirestoreService().storeDonation(userId!, donationData);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'donations': FieldValue.arrayUnion([
          {
            'orphanageTitle': _orphanageTitleController.text,
            'amount': double.parse(_amountController.text),
            'transactionId': _transactionIdController.text,
            'type': 'amount',
            'timestamp': currentTimestamp,
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation Recorded Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate Money'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(_orphanageTitleController, 'Orphanage', readOnly: true),
                  _buildInputField(_nameController, 'Donor Name', validator: (value) {
                    return value!.isEmpty ? 'Enter name' : null;
                  }),
                  _buildInputField(
                    _emailController,
                    'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)
                          ? 'Enter a valid email'
                          : null;
                    },
                  ),
                  _buildInputField(
                    _mobileController,
                    'Mobile No (+91)',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      return value!.length != 10 ? 'Enter a valid 10-digit number' : null;
                    },
                  ),
                  _buildInputField(
                    _amountController,
                    'Amount to Pay',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.currency_rupee,
                    validator: (value) {
                      return value!.isEmpty ? 'Enter amount' : null;
                    },
                  ),
                  _buildInputField(
                    _transactionIdController,
                    'Transaction ID',
                    prefixIcon: Icons.confirmation_number,
                    validator: (value) {
                      return value!.isEmpty ? 'Enter transaction ID' : null;
                    },
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Scan QR Code to Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Image.asset('assets/qr.jpeg', height: 150),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        IconData? prefixIcon,
        String? Function(String?)? validator,
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.deepPurple) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
