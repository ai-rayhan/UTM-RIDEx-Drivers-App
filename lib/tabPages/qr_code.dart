import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeTabPage extends StatefulWidget {
  const QRCodeTabPage({Key? key}) : super(key: key);

  @override
  State<QRCodeTabPage> createState() => _QRCodeTabPageState();
}

class _QRCodeTabPageState extends State<QRCodeTabPage> {
  String downloadUrlImage = "";
  String realQrCode =
      "https://firebasestorage.googleapis.com/v0/b/ride-sharing-application-9de92.appspot.com/o/driversQR%2Fplain%20image.png?alt=media&token=564a9a09-a571-44fb-8bbb-b30f2f19d924";
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();
  bool isLoading = false; // Loading state

  getImageFromGallery() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imgXFile;
    });
  }

  formValidation() async {
    if (imgXFile == null) {
      Fluttertoast.showToast(msg: "Please select an image");
    } else {
      setState(() {
        isLoading = true; // Start loading
      });

      // Upload image to Firebase Storage
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("driversQR")
          .child(fileName);

      fStorage.UploadTask uploadImageTask =
          storageRef.putFile(File(imgXFile!.path));

      fStorage.TaskSnapshot taskSnapshot =
          await uploadImageTask.whenComplete(() {});

      await taskSnapshot.ref.getDownloadURL().then((urlImage) {
        downloadUrlImage = urlImage;
      });

      // Realtime Database
      DatabaseReference driversRef =
          FirebaseDatabase.instance.ref().child("drivers");
      await driversRef
          .child(currentFirebaseUser!.uid)
          .child("photoUrl")
          .set(downloadUrlImage);

      // Save to Firestore
      FirebaseFirestore.instance
          .collection("drivers")
          .doc(currentFirebaseUser!.uid)
          .set({
        "uid": currentFirebaseUser!.uid,
        "email": currentFirebaseUser!.email,
        "name": currentFirebaseUser!.displayName,
        "photoUrl": downloadUrlImage,
      });

      // Save locally
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences!.setString("photoUrl", downloadUrlImage);

      AssistantMethods.readUrlImageDriver(context);
      await getRealQrCode();
      setState(() {
        isLoading = false; // Stop loading
        realQrCode = downloadUrlImage; // Update the displayed QR code
        imgXFile = null; // Clear the selected image
      });
    }
  }

  readUrlInformation() {
    currentFirebaseUser = fAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.photo_url = (snap.snapshot.value as Map)["photoUrl"];
        setState(() {
          realQrCode = onlineDriverData.photo_url!;
        });
      }
    });
  }

  getRealQrCode() {
    if (onlineDriverData.photo_url != null) {
      return onlineDriverData.photo_url!;
    } else {
      return "https://firebasestorage.googleapis.com/v0/b/ride-sharing-application-9de92.appspot.com/o/driversQR%2Fplain%20image.png?alt=media&token=564a9a09-a571-44fb-8bbb-b30f2f19d924";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readUrlInformation();
    getRealQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),

              // Capture or get picture QR from gallery
              GestureDetector(
                onTap: () {
                  getImageFromGallery();
                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.08,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      imgXFile == null ? null : FileImage(File(imgXFile!.path)),
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                onPressed: () {
                  formValidation();
                },
                child: const Text(
                  "Upload QR-Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (isLoading) // Show loading indicator
                const CircularProgressIndicator(),

              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Image.network(realQrCode),
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
