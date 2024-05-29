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
  String realQrCode = "";
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();

  getImageFromGallery() async
  {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState((){
      imgXFile;
    });
  }

  formValidation() async
  {
    if(imgXFile == null) //image not selected
      {
        Fluttertoast.showToast(msg: "Please select an image");
    }
    else
      {
        //upload image to firebase storage
        String fileName = DateTime.now().microsecondsSinceEpoch.toString();
        fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
            .ref()
            .child("driversQR").child(fileName);

        fStorage.UploadTask uploadImageTask = storageRef.putFile(File(imgXFile!.path));

        fStorage.TaskSnapshot taskSnapshot = await uploadImageTask.whenComplete(() {});

        await taskSnapshot.ref.getDownloadURL().then((urlImage)
        {
          downloadUrlImage = urlImage;
        });

        //realtime database
        DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
        driversRef.child(currentFirebaseUser!.uid).child("photoUrl").set(downloadUrlImage) as String;


        //save to firestore
        FirebaseFirestore.instance
            .collection("drivers")
            .doc(currentFirebaseUser!.uid)
            .set(
          {
           "uid": currentFirebaseUser!.uid,
           "email": currentFirebaseUser!.email,
           "name": currentFirebaseUser!.displayName,
           "photoUrl": downloadUrlImage,
          });

        //save locally
        sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences!.setString("photoUrl",downloadUrlImage);

        AssistantMethods.readUrlImageDriver(context);

      }


  }

  readUrlInformation()
  {
    currentFirebaseUser = fAuth.currentUser;
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        onlineDriverData.photo_url = (snap.snapshot.value as Map)["photoUrl"];
      }
    });
  }

  getRealQrCode()
  {
    if(onlineDriverData.photo_url != null)
      {
        return onlineDriverData.photo_url;
      }
    else
      {
        return "https://firebasestorage.googleapis.com/v0/b/ride-sharing-application-9de92.appspot.com/o/driversQR%2Fplain%20image.png?alt=media&token=564a9a09-a571-44fb-8bbb-b30f2f19d924";
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readUrlInformation();
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

                const SizedBox(height: 100,),

                //capture or get picture qr from gallery
                GestureDetector(
                  onTap: ()
                  {
                    getImageFromGallery();
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.05,
                    backgroundColor: Colors.white,
                    backgroundImage: imgXFile == null
                        ? null
                        : FileImage(
                          File(imgXFile!.path)
                        ),
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.grey,
                      size: MediaQuery.of(context).size.width * 0.05,
                    ),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  ),
                    onPressed: ()
                    {
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

                Container( //see video 12
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width * 0.9,
                    child: Image.network(
                      realQrCode = getRealQrCode(),
                        //"https://firebasestorage.googleapis.com/v0/b/ride-sharing-application-9de92.appspot.com/o/driversQR%2F1674054226945938?alt=media&token=70e5ab04-2b34-4531-a66f-9293e5386f3c",
                      //Provider.of<AppInfo>(context, listen: false).driverQRCode,
                      //onlineDriverData.photo_url! != null
                        //  ? "https://www.google.com/imgres?imgurl=https%3A%2F%2Fwww.publicdomainpictures.net%2Fpictures%2F30000%2Fnahled%2Fplain-white-background.jpg&imgrefurl=https%3A%2F%2Fwww.publicdomainpictures.net%2Fen%2Fview-image.php%3Fimage%3D28763%26picture%3Dplain-white-background&tbnid=zYz17kVpIDpcMM&vet=12ahUKEwir7O6j4dL8AhVpN7cAHfxHD2EQMygAegUIARDDAQ..i&docid=dvT8b8TucUY-MM&w=615&h=410&q=square%20plain%20white%20image&ved=2ahUKEwir7O6j4dL8AhVpN7cAHfxHD2EQMygAegUIARDDAQ"
                          //: onlineDriverData.photo_url!
                      ),
                      //sharedPreferences!.getString("photoUrl")!,
                    ),

                    //backgroundImage: onlineDriverData!.photoUrl! == null ? null : FileImage(
                        //File(onlineDriverData!.photoUrl!)),
                    //backgroundImage: NetworkImage(
                      //onlineDriverData!.photoUrl!,
                    //),



                const SizedBox(height: 10,),

              ],
            ),
          )
      ),
    );
  }
}
