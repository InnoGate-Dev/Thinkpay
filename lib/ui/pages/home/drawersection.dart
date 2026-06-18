import 'package:flutter/material.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.lightGreenAccent,
          ),
          child: Center(child: Text('Drawer Header')),
        ),
        Expanded(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: const [
              ListTile(
                title: Text('Home'),
              ),
              ListTile(
                title: Text('Business'),
              ),
              ListTile(
                title: Text('School'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
