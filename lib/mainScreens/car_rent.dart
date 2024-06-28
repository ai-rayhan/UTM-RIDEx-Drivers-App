import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:fluttertoast/fluttertoast.dart';

class MonthlyORHourlyBasis extends StatefulWidget {
  @override
  _MonthlyORHourlyBasisState createState() => _MonthlyORHourlyBasisState();
}

class _MonthlyORHourlyBasisState extends State<MonthlyORHourlyBasis> {
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String _selectedType = 'Hourly';
  bool _isLoading = false;
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();
  String? downloadUrlImage;

  Future<void> getImageFromGallery() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imgXFile;
    });
  }

  Future<void> uploadImage() async {
    if (imgXFile == null) {
      Fluttertoast.showToast(msg: "Please select an image");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
        .ref()
        .child("rentalImages")
        .child(fileName);

    fStorage.UploadTask uploadImageTask =
        storageRef.putFile(File(imgXFile!.path));
    fStorage.TaskSnapshot taskSnapshot =
        await uploadImageTask.whenComplete(() {});
    downloadUrlImage = await taskSnapshot.ref.getDownloadURL();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _postVehicle() async {
    if (imgXFile != null && downloadUrlImage == null) {
      await uploadImage();
    }

    setState(() {
      _isLoading = true;
    });

    final id = DateTime.now().toIso8601String();
    final type = _selectedType;
    final fee = _feeController.text;
    final vehicleType = _vehicleTypeController.text;
    final vehicleModel = _vehicleModelController.text;
    final contact = _contactController.text;

    final url =
        'https://friendly-folio-425114-v9-default-rtdb.firebaseio.com/rental.json';

    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'id': id,
        'type': type,
        'fee': fee,
        'vehicle_type': vehicleType,
        'vehicle_model': vehicleModel,
        'contact': contact,
        'imgurl': downloadUrlImage,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      _clearTextFields();
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post vehicle.')),
      );
    }
  }

  void _clearTextFields() {
    _feeController.clear();
    _vehicleTypeController.clear();
    _vehicleModelController.clear();
    _contactController.clear();
    imgXFile = null;
    downloadUrlImage = null;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Vehicle posted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Navigate back
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Rental Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('Hourly'),
                  selected: _selectedType == 'Hourly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = 'Hourly';
                    });
                  },
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text('Monthly'),
                  selected: _selectedType == 'Monthly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = 'Monthly';
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: _feeController,
              decoration: InputDecoration(labelText: 'Fee'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _vehicleTypeController,
              decoration: InputDecoration(labelText: 'Vehicle Type'),
            ),
            TextField(
              controller: _vehicleModelController,
              decoration: InputDecoration(labelText: 'Vehicle Model'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                getImageFromGallery();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.08,
                backgroundColor: Colors.grey,
                backgroundImage:
                    imgXFile == null ? null : FileImage(File(imgXFile!.path)),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _postVehicle,
                    child: Text('Post Vehicle'),
                  ),
          ],
        ),
      ),
    );
  }
}
