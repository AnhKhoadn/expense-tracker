import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/pages/setting_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [
            DrawerHeader(child: Image.asset('assets/images/logo.png')),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('H O M E', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('S E T T I N G', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
