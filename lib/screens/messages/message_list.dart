import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yclcall/screens/messages/message.dart';
import 'package:yclcall/screens/userDashboard.dart';
import 'message_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    Key? key,
    required this.name,
    required this.whatsBothering,
    required this.modeOfContact,
  }) : super(key: key);
  final String name;
  final String whatsBothering;
  final String modeOfContact;

  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? docID;
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser!.uid}");
  @override
  void initState() {
    addToFirebase();
    print(FirebaseAuth.instance.currentUser!.uid);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const UserDashboard(),
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection("calls").doc(docID).set(
        {
          'status': "Completed",
          'completedTime': DateFormat('MM-dd-yyyy, hh:mm a')
              .format(DateTime.now())
              .toString(),
          'msSinceEpochDone': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );
      await FirebaseDatabase.instance
          .ref("messages/${FirebaseAuth.instance.currentUser!.uid}")
          .push()
          .set({
        'date': DateTime.now().toString(),
        'text': "Caller has left the chat.",
        'uid': FirebaseAuth.instance.currentUser!.uid,
      });
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const UserDashboard(),
        ),
      );
    }
  }

  String? mtoken = " ";
  addToFirebase() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });
    });
    await FirebaseFirestore.instance.collection("calls").add(
      {
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'status': "Awaiting",
        'msSinceEpoch': DateTime.now().millisecondsSinceEpoch,
        'time':
            DateFormat('MM-dd-yyyy, hh:mm a').format(DateTime.now()).toString(),
        "timeStamp": DateTime.now(),
        'deviceToken': mtoken,
        'name': widget.name,
        'whatsBothering': widget.whatsBothering,
        'modeOfContact': widget.modeOfContact,
      },
    ).then(
      (value) {
        Fluttertoast.showToast(msg: 'Request placed');
      },
    );
  }

  endChat() async {
    await FirebaseFirestore.instance.collection("calls").doc(docID).set(
      {
        'status': "Completed",
        'completedTime':
            DateFormat('MM-dd-yyyy, hh:mm a').format(DateTime.now()).toString(),
        'msSinceEpochDone': DateTime.now().millisecondsSinceEpoch,
      },
      SetOptions(merge: true),
    );
    await FirebaseDatabase.instance
        .ref("messages/${FirebaseAuth.instance.currentUser!.uid}")
        .push()
        .set({
      'date': DateTime.now().toString(),
      'text': "Caller has left the chat.",
      'uid': FirebaseAuth.instance.currentUser!.uid,
    });
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const UserDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xff00b894);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: secondaryColor,
        elevation: 0,
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('calls')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(), // async work
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Text('Loading....');
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: snapshot.data!.docs.map(
                      (DocumentSnapshot document) {
                        docID = document.id;
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return data["status"] == "Awaiting"
                            ? Text(
                                data["status"].toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              )
                            : Text(
                                "${data["counselorName"]}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              );
                      },
                    ).toList(),
                  );
                }
            }
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: GestureDetector(
              onTap: () async {
                endChat();
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Icon(
                  FontAwesomeIcons.circleCheck,
                ),
              ),
            ),
          ),
        ],
        leading: GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 37, 41, 41),
      body: Column(
        children: [
          _getMessageList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 11,
                child: TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  controller: _messageController,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    labelText: 'Enter message',
                    labelStyle: GoogleFonts.poppins(color: Colors.white),
                    focusColor: Colors.white,
                    fillColor: Colors.white,
                    hoverColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 3, color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  iconSize: 30,
                  color: Colors.white,
                  icon: Icon(
                    _canSendMessage()
                        ? CupertinoIcons.arrow_right_circle_fill
                        : CupertinoIcons.arrow_right_circle,
                  ),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_canSendMessage()) {
      final message = Message(_messageController.text, DateTime.now(), 'ee');
      FirebaseDatabase.instance
          .ref("messages/${FirebaseAuth.instance.currentUser!.uid}")
          .push()
          .set(message.toJson());
      _messageController.clear();
      setState(() {});
    }
  }

  Widget _getMessageList() {
    return Expanded(
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        query: FirebaseDatabase.instance
            .ref("messages/${FirebaseAuth.instance.currentUser!.uid}")
            .orderByChild("date"),
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final message = Message.fromJson(json);
          return MessageWidget(message.text, message.date, message.uid);
        },
      ),
    );
  }

  bool _canSendMessage() => _messageController.text.isNotEmpty;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
