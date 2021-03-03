import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:event/event.dart';
import 'package:shopping_list/service/MessageEventArgs.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  final onMessageEvent = Event<MessageEventArgs>();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (!_initialized) {
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(onMessage: _onMessageHandler);
      _initialized = true;
    }
  }

  Future<void> _onMessageHandler(Map<String, dynamic> inputMessage) async {
    onMessageEvent.broadcast(MessageEventArgs(
        inputMessage["notification"]["title"],
        inputMessage["notification"]["body"]));
  }
}
