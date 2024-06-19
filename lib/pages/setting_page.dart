import 'package:expense_tracker/theme/my_theme.dart';
import 'package:expense_tracker/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});

  dynamic isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('S E T T I N G'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          height: 80,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dark mode', style: TextStyle(fontSize: 20)),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return CupertinoSwitch(
                    value: themeProvider.themeData == darkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
