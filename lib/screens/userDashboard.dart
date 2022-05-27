import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yclcall/screens/messages/message_list.dart';
import 'package:http/http.dart' as http;
import 'package:yclcall/screens/pageviewer.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    initializeFCM();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  signInAnonymously() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  signOutAnonymously() async {
    await FirebaseAuth.instance.signOut();
  }

  void initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } else {
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    await FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'launch_background',
              ),
            ),
          );
        }
      },
    );
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'Crisis_Help_Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAh5jveYY:APA91bHf84RWq2n2F9cl2HEKnasMGXH4cfRtf_0S-aCzklQFSYx3tXarfDvSfA3H0d9CtcdlTqh6aqfdlxvU8WPM33H_lAVxXkjXOtDKq9oXymkhuacvy4ctutXlqxR7Au5LbbK82z-x',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': 'Youth Crisis Line',
              'body': 'Someone needs your help!',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": "/topics/counselors",
          },
        ),
      );
      print('done');
    } catch (e) {}
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    TextEditingController whatsBothering = TextEditingController();
    TextEditingController modeOfContact = TextEditingController();
    const backgroundColor = Color(0xff252929);
    const secondaryColor = Color(0xff00b894);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Text(
            'Youth Crisis Line',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 40, right: 40, bottom: 40),
                child: Bounceable(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      bounce: true,
                      backgroundColor: backgroundColor,
                      context: context,
                      builder: (context) {
                        return SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 40, left: 40, right: 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Get Help',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: secondaryColor,
                                    onPrimary: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(140.0),
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text(
                                            'Call Youth Crisis Line'),
                                        content: const Text(
                                            'Are you sure you want to call Youth Crisis Line?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, 'Cancel'),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await FlutterPhoneDirectCaller
                                                  .callNumber('4434290059');
                                            },
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Speak with a Counselor',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: secondaryColor,
                                    onPrimary: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(140.0),
                                    ),
                                    minimumSize: const Size(
                                        double.infinity, 50), //////// HERE
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: backgroundColor,
                                      context: context,
                                      builder: (context) =>
                                          SingleChildScrollView(
                                        controller:
                                            ModalScrollController.of(context),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 40, left: 40, right: 50),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Details',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    'Add a few details to get started. \n(Only name/nickname is required)',
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                TextField(
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  controller: name,
                                                  cursorColor: Colors.white,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    labelText:
                                                        'Name or Nickname',
                                                    labelStyle:
                                                        GoogleFonts.poppins(
                                                            color:
                                                                Colors.white),
                                                    focusColor: Colors.white,
                                                    fillColor: Colors.white,
                                                    hoverColor: Colors.white,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        width: 3,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 3,
                                                              color:
                                                                  Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                TextField(
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  controller: whatsBothering,
                                                  cursorColor: Colors.white,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    labelText:
                                                        'What\'s bothering you?',
                                                    labelStyle:
                                                        GoogleFonts.poppins(
                                                            color:
                                                                Colors.white),
                                                    focusColor: Colors.white,
                                                    fillColor: Colors.white,
                                                    hoverColor: Colors.white,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        width: 3,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 3,
                                                              color:
                                                                  Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                TextField(
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  controller: modeOfContact,
                                                  cursorColor: Colors.white,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    labelText:
                                                        'Mode of contact to checkup',
                                                    labelStyle:
                                                        GoogleFonts.poppins(
                                                            color:
                                                                Colors.white),
                                                    focusColor: Colors.white,
                                                    fillColor: Colors.white,
                                                    hoverColor: Colors.white,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        width: 3,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 3,
                                                              color:
                                                                  Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: secondaryColor,
                                                    onPrimary: Colors.white,
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              140.0),
                                                    ),
                                                    minimumSize: const Size(
                                                        double.infinity,
                                                        50), //////// HERE
                                                  ),
                                                  onPressed: () async {
                                                    if (name.text == "") {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'Name/Nickname is left blank.');
                                                    } else {
                                                      await signOutAnonymously();
                                                      await signInAnonymously();
                                                      sendPushMessage();

                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MessageList(
                                                            modeOfContact:
                                                                modeOfContact
                                                                    .text,
                                                            whatsBothering:
                                                                whatsBothering
                                                                    .text
                                                                    .toString(),
                                                            name: name.text,
                                                          ),
                                                        ),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false,
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    'Start Chat',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Message a Counselor',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: secondaryColor,
                    ),
                    child: Center(
                      child: Text(
                        'Get Help',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40, right: 40, left: 40),
                child: Bounceable(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      bounce: true,
                      backgroundColor: backgroundColor,
                      context: context,
                      builder: (context) => SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 30, right: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Access Resources',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: secondaryColor,
                                  onPrimary: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(140.0),
                                  ),
                                  minimumSize: const Size(
                                      double.infinity, 50), //////// HERE
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PageViewer(
                                        title: "Homelessness",
                                        url:
                                            "https://ycl.care/youth-homelessness",
                                      ),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Text(
                                  'Homelessness',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: secondaryColor,
                                  onPrimary: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(140.0),
                                  ),
                                  minimumSize: const Size(
                                      double.infinity, 50), //////// HERE
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PageViewer(
                                        title: "Gender Identity",
                                        url:
                                            "https://gender.islamicleadership.org/",
                                      ),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                  // launchURI(
                                  //     "http://gender.islamicleadership.org/");
                                },
                                child: Text(
                                  'Gender Identity',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: secondaryColor,
                                  onPrimary: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(140.0),
                                  ),
                                  minimumSize: const Size(
                                      double.infinity, 50), //////// HERE
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PageViewer(
                                        title: "Value of Life",
                                        url:
                                            "https://life.islamicleadership.org/",
                                      ),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Text(
                                  'Value of Life',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Access\nYCL Resources',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
