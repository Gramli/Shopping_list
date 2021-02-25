import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:event/event.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  final onMessageEvent = Event();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (!_initialized) {
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
          onMessage: _onMessageHandler, onResume: _onResumeHandler);

      _initialized = true;
    }
  }

  void _onMessageHandler(Map<String, dynamic> inputMessage) {
    print(inputMessage["data"]["title"]);
    onMessageEvent.broadcast();
  }

  void _onResumeHandler(Map<String, dynamic> inputMessage) {
    print(inputMessage["data"]["title"]);
    onMessageEvent.broadcast();
  }
}
