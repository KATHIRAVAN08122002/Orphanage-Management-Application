import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DonateFoodPage extends StatefulWidget {
  final String orphanageTitle;

  DonateFoodPage({required this.orphanageTitle});

  @override
  _DonateFoodPageState createState() => _DonateFoodPageState();
}

class _DonateFoodPageState extends State<DonateFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _parcelsController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc['name'] ?? '';
          _emailController.text = doc['email'] ?? '';
          _phoneController.text = doc['phone'] ?? '';
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && userId != null) {
      Timestamp currentTimestamp = Timestamp.now();

      final donationData = {
        'orphanage': widget.orphanageTitle,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'donationDate': _dateController.text,
        'donationTime': _timeController.text,
        'numberOfParcels': int.parse(_parcelsController.text),
        'timestamp': currentTimestamp,
      };

      await FirebaseFirestore.instance.collection('donation_food').add(donationData);
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'donations': FieldValue.arrayUnion([
          {
            'orphanageTitle': widget.orphanageTitle,
            'donationDate': _dateController.text,
            'donationTime': _timeController.text,
            'numberOfParcels': int.parse(_parcelsController.text),
            'type': 'food',
            'timestamp': currentTimestamp,
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Food Donation Recorded Successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate Food'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(TextEditingController(text: widget.orphanageTitle), 'Orphanage', readOnly: true),
                  _buildInputField(_nameController, 'Donor Name', validator: (value) => value!.isEmpty ? 'Enter name' : null),
                  _buildInputField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!) ? 'Enter a valid email' : null),
                  _buildInputField(_phoneController, 'Mobile No (+91)', keyboardType: TextInputType.phone, validator: (value) => value!.length != 10 ? 'Enter a valid 10-digit number' : null),
                  _buildInputField(_dateController, 'Select Date', onTap: () => _selectDate(context), readOnly: true),
                  _buildInputField(_timeController, 'Select Time', onTap: () => _selectTime(context), readOnly: true),
                  _buildInputField(_parcelsController, 'Number of Parcels', keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Enter number of parcels' : null),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        validator: validator,
        onTap: onTap,
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