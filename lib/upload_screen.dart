// Enhanced Upload Page with Additional Fields and Responsive UI
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  final picker = ImagePicker();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _flatNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedState = 'Tamil Nadu';
  bool _isLoading = false;
  final List<String> _states = ['Tamil Nadu', 'Kerala', 'Karnataka', 'Andhra Pradesh', 'Telangana'];

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/dlbnmofqx/image/upload'))
        ..fields['upload_preset'] = 'orphanage'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData)['secure_url'];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
    }
    return null;
  }

  Future<void> _submitForm() async {
    if ([_idController, _nameController, _placeController, _flatNoController, _streetController, _cityController, _pincodeController, _mobileController].any((c) => c.text.isEmpty) || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? imageUrl = await uploadImageToCloudinary(_image!);
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('orphanages').add({
          'id': _idController.text,
          'name': _nameController.text,
          'title':_nameController.text,
          'place': _placeController.text,
          'flat_no': _flatNoController.text,
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _selectedState,
          'pincode': _pincodeController.text,
          'mobile': '+91${_mobileController.text}',
          'image': imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded Successfully!')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Orphanage Info')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_idController, 'Orphanage ID', TextInputType.text),
            _buildTextField(_nameController, 'Orphanage Name', TextInputType.text),
            _buildTextField(_placeController, 'Place', TextInputType.text),
            _buildTextField(_flatNoController, 'Flat No', TextInputType.text),
            _buildTextField(_streetController, 'Street', TextInputType.text),
            _buildTextField(_cityController, 'City', TextInputType.text),
            DropdownButtonFormField(
              value: _selectedState,
              items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
              onChanged: (value) => setState(() => _selectedState = value as String),
              decoration: InputDecoration(labelText: 'State', border: OutlineInputBorder()),
            ),
            _buildTextField(_pincodeController, 'Pincode (6 digits)', TextInputType.number),
            _buildTextField(_mobileController, 'Mobile (+91)', TextInputType.phone),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
            if (_image != null) Image.file(_image!, height: 150),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: _submitForm, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
