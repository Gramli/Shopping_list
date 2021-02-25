import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
          onMessage: _onMessage, onLaunch: _onLaunch, onResume: _onResume);

      _initialized = true;
    }
  }

  void _onMessage(Map<String, dynamic> inputMessage) {}
  void _onLaunch(Map<String, dynamic> inputMessage) {}
  void _onResume(Map<String, dynamic> inputMessage) {}

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
}
