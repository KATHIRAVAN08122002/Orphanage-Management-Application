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
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _aboutController = TextEditingController();
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
    if ([_idController, _nameController, _placeController, _flatNoController, _streetController, _cityController, _pincodeController, _mobileController, _latitudeController, _longitudeController, _aboutController]
        .any((c) => c.text.isEmpty) || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? imageUrl = await uploadImageToCloudinary(_image!);
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('verification').add({
          'id': _idController.text,
          'name': _nameController.text,
          'title': _nameController.text,
          'place': _placeController.text,
          'flat_no': _flatNoController.text,
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _selectedState,
          'pincode': _pincodeController.text,
          'mobile': '+91${_mobileController.text}',
          'loc': [double.parse(_latitudeController.text), double.parse(_longitudeController.text)],
          'about': _aboutController.text,
          'image': imageUrl,
          'verified': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submitted for Verification!')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Orphanage Info'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                _buildTextField(_latitudeController, 'Latitude', TextInputType.number),
                _buildTextField(_longitudeController, 'Longitude', TextInputType.number),
                _buildTextField(_aboutController, 'About the Orphanage', TextInputType.multiline, maxLines: 5),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Pick Image'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                if (_image != null) Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_image!, height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
