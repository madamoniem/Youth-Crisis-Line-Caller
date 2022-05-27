import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String text;
  final String uid;
  final DateTime date;

  Message(this.text, this.date, this.uid);

  Message.fromJson(Map<dynamic, dynamic> json)
      : date = DateTime.parse(json['date'] as String),
        text = json['text'] as String,
        uid = json['uid'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'date': date.toString(),
        'text': text,
        'uid': FirebaseAuth.instance.currentUser!.uid
      };
}
