import 'package:event/event.dart';

class MessageEventArgs extends EventArgs {
  String title;
  String message;
  MessageEventArgs(this.title, this.message);
}
