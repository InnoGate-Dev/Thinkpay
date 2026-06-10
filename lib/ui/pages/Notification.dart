import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationState();
}
const _kDark = Color(0xFF0A0A0A);
class _NotificationState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      appBar: AppBar(
        //backgroundColor: _kDark,

        title: Text('Notification'),
      ),

    );
  }
}
