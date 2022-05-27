import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final String id;
  final DateTime date;

  const MessageWidget(this.message, this.date, this.id);

  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xff00b894);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Align(
        alignment: id == FirebaseAuth.instance.currentUser!.uid
            ? Alignment.bottomRight
            : Alignment.bottomLeft,
        child: Padding(
          padding: id == FirebaseAuth.instance.currentUser!.uid
              ? const EdgeInsets.only(right: 20)
              : const EdgeInsets.only(left: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Column(
              children: [
                Align(
                  alignment: id == FirebaseAuth.instance.currentUser!.uid
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: id == FirebaseAuth.instance.currentUser!.uid
                          ? Color(0xff0984e3)
                          : (message == "Counselor has left the chat." ||
                                  message == "Caller has left the chat.")
                              ? const Color(0xffe17055)
                              : secondaryColor,
                    ),
                    child: Wrap(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            message,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: id == FirebaseAuth.instance.currentUser!.uid
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: Padding(
                    padding: id == FirebaseAuth.instance.currentUser!.uid
                        ? const EdgeInsets.only(right: 0)
                        : const EdgeInsets.only(left: 0),
                    child: Text(
                      DateFormat('MM-dd-yyyy, hh:mm a').format(date).toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
