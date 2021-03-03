import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:event/event.dart';
import 'package:shopping_list/service/MessageEventArgs.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  final String _msgNotificationKey = "notification";
  final String _msgTitleKey = "title";
  final String _msgBodyKey = "body";

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
      _firebaseMessaging.configure(onMessage: _onNotificationMessageHandler);
      _initialized = true;
    }
  }

  Future<void> _onNotificationMessageHandler(
      Map<String, dynamic> inputMessage) async {
    try {
      if (!inputMessage.containsKey(_msgNotificationKey)) {
        return;
      }

      var inputMessageBody = inputMessage[_msgNotificationKey];

      if (inputMessageBody.containsKey(_msgTitleKey) &&
          inputMessageBody.containsKey(_msgBodyKey)) {
        onMessageEvent.broadcast(MessageEventArgs(
            inputMessage[_msgNotificationKey][_msgTitleKey],
            inputMessage[_msgNotificationKey][_msgBodyKey]));
      }
    } catch (ex) {
      print(ex);
    }
  }
}
