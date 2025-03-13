import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  final String orphanageTitle;

  AppointmentScreen({required this.orphanageTitle});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  bool _isLoading = true;
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
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (doc.exists) {
          setState(() {
            _nameController.text = doc['name'] ?? '';
            _emailController.text = doc['email'] ?? '';
            _phoneController.text = '+91 ${doc['phone'] ?? ''}';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
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

  void _submitAppointment() async {
    if (_formKey.currentState!.validate() && userId != null) {
      Timestamp currentTimestamp = Timestamp.now();
      try {
        await FirebaseFirestore.instance.collection('appointments').add({
          'donorId': userId,
          'donorName': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'orphanageTitle': widget.orphanageTitle,
          'appointmentDate': _dateController.text,
          'appointmentTime': _timeController.text,
          'timestamp': currentTimestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment booked successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool readOnly = false, IconData? prefixIcon, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: onTap,
        validator: (value) {
          return value!.isEmpty ? 'Enter $label' : null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputField(_nameController, 'Name', readOnly: true),
              _buildInputField(_emailController, 'Email', readOnly: true),
              _buildInputField(_phoneController, 'Phone', readOnly: true),
              _buildInputField(TextEditingController(text: widget.orphanageTitle), 'Orphanage', readOnly: true),
              _buildInputField(
                _dateController,
                'Appointment Date',
                readOnly: true,
                prefixIcon: Icons.calendar_today,
                onTap: () => _selectDate(context),
              ),
              _buildInputField(
                _timeController,
                'Appointment Time',
                readOnly: true,
                prefixIcon: Icons.access_time,
                onTap: () => _selectTime(context),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}