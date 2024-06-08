import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  
  List<String> carTypesList = ["Sedan", "Hatchback", "MPV", "SUV"];
  List<String> bikeTypesList = ["Sport", "Cruiser", "Scooter"];
  String? selectedVehicleType;
  String selectedVehicle = 'Car';
  bool _wantsDelivery = false;

  saveCarInfo()
  {
    Map driverCarInfoMap = {
      "car_color": vehicleColorTextEditingController.text.trim(),
      "car_number": vehicleNumberTextEditingController.text.trim(),
      "car_model": vehicleModelTextEditingController.text.trim(),
      "type": selectedVehicleType,
      "vehicle_category": selectedVehicle,
      "delivery": _wantsDelivery ? "yes" : "no",
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
    driversRef.child(currentFirebaseUser!.uid).child("car_details").set(driverCarInfoMap);

    Fluttertoast.showToast(msg: "Car detail has been saved. Congratulations!");
    Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("images/logo2.png"),
              ),
              const SizedBox(height: 10),
              const Text(
                "Fill Vehicle Details",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: vehicleModelTextEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Vehicle Model",
                  hintText: "Vehicle Model",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              TextField(
                controller: vehicleNumberTextEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Vehicle Number",
                  hintText: "Vehicle Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              TextField(
                controller: vehicleColorTextEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Vehicle Color",
                  hintText: "Vehicle Color",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Car", style: TextStyle(color: Colors.grey)),
                      value: 'Car',
                      groupValue: selectedVehicle,
                      onChanged: (value) {
                        setState(() {
                          selectedVehicle = value!;
                          selectedVehicleType = null;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Bike", style: TextStyle(color: Colors.grey)),
                      value: 'Bike',
                      groupValue: selectedVehicle,
                      onChanged: (value) {
                        setState(() {
                          selectedVehicle = value!;
                          selectedVehicleType = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                iconSize: 26,
                icon: const Icon(Icons.adf_scanner),
                dropdownColor: Colors.black,
                hint: Text(
                  "Please Choose ${selectedVehicle == 'Car' ? 'Car' : 'Bike'} Type",
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                value: selectedVehicleType,
                onChanged: (newValue) {
                  setState(() {
                    selectedVehicleType = newValue;
                  });
                },
                items: (selectedVehicle == 'Car' ? carTypesList : bikeTypesList).map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text("I want to deliver products", style: TextStyle(color: Colors.grey)),
                value: _wantsDelivery,
                onChanged: (value) {
                  setState(() {
                    _wantsDelivery = value!;
                  });
                },
                checkColor: Colors.black,
                activeColor: Colors.grey,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (vehicleColorTextEditingController.text.isNotEmpty &&
                      vehicleNumberTextEditingController.text.isNotEmpty &&
                      vehicleModelTextEditingController.text.isNotEmpty &&
                      selectedVehicleType != null) {
                    saveCarInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Save Now",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
