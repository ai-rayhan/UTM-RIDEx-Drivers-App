import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _postVehicle() async {
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
