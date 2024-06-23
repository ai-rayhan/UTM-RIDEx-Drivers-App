import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission(
        // sound: true,
        // alert: true,
        // announcement: false,
        // badge: true,
        // carPlay: false,
        // criticalAlert: false,
        // provisional: false,
        );
  }

  Future<void> initialize() async {
    await requestPermission();

    // Normal/ALIVE/ON-PAUSE
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification?.title);
      print(message.notification?.body);
      print(message.data);
    });

    // OPEN/RESUME
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message.notification?.title);
      print(message.notification?.body);
      print(message.data);
    });

    // DEAD/ON-TERMINATED
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
  }

  Future<void> getFCMToken() async {
    final token = await _firebaseMessaging.getToken();
    print("fcm token is $token");
  }

  Future<void> onRefresh(Function(String) onTokenRefresh) async {
    _firebaseMessaging.onTokenRefresh.listen((token) {
      onTokenRefresh(token);
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeToTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

Future<void> handleBackgroundNotification(RemoteMessage message) async {}

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the received message when the app is in the foreground
      print(
          'Received message while app is in foreground: ${message.notification!.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the received message when the app is opened from a terminated state
      print('Opened app from terminated state: ${message.notification!.body}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission for receiving notifications
    NotificationSettings settings = await messaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Handle background messages
    print('Handling a background message: ${message.notification!.body}');
  }
}
