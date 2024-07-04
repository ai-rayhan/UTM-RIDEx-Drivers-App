import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:drivers_app/models/user_ride_Request_information.dart';
import 'package:drivers_app/push_notifications/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {

   FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async
  {
    //1. terminated - when app completely close n opened direct from app noti
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){
      if(remoteMessage != null)
        {
          //display ride request info from user


       Navigator.pushReplacement<void, void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>  MainScreen(),
    ),
  );        }
    });

    //2. foreground - when app is open and receive notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {


       Navigator.pushReplacement<void, void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>  MainScreen(),
    ),
  );    });

    //3. background - when app in background n open direct from app noti
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {

       Navigator.pushReplacement<void, void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>  MainScreen(),
    ),
  );
    });
  }

 Future generateAndGetToken() async
  {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);


    FirebaseDatabase.instance.ref().child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("token").set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
  checkHasRequest(BuildContext context) {
    String getRideRequestId = "";
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null &&
          snap.snapshot.value.toString().length > 9) {
        getRideRequestId = snap.snapshot.value.toString();
        readUserRideRequestInformation(getRideRequestId, context);
      } else {
        log(snap.snapshot.value.toString());
      }
    });
  }

  readUserRideRequestInformation(String riderRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Request")
        .child(riderRequestId)
        .once()
        .then((snapData) {
      if (snapData.snapshot.value != null) {
        log(snapData.snapshot.value.toString());
        audioPlayer.open(Audio("music/sound_notification.mp3"));
        audioPlayer.play();
        var value = (snapData.snapshot.value! as Map);
        // var value=snapdataMap[snapdataMap.keys.first];
        double originLat = double.parse(value["origin"]["latitude"]);
        double originLng = double.parse(value["origin"]["longitude"]);
        String originAddress = value["originAddress"];

        double destinationLat = double.parse(value["destination"]["latitude"]);
        double destinationLng = double.parse(value["destination"]["longitude"]);
        String destinationAddress = value["destinationAddress"];

        String userName = value["userName"];
        String userPhone = value["userPhone"];

        String? rideRequestId = snapData.snapshot.key;

        UserRideRequestInformation userRideRequestDetails =
            UserRideRequestInformation();
        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;

        userRideRequestDetails.rideRequestId = rideRequestId;

        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "This Ride Request Id not exist");
      }
    });
  }
}
