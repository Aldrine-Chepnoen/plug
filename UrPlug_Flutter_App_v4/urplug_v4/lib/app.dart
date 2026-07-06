import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as pv;
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/auth/phone_login_screen.dart';

class UrPlugApp extends StatelessWidget {
  const UrPlugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return pv.ChangeNotifierProvider(
      create: (_) => AppState(),
      child: pv.Consumer<AppState>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'Ur Plug',
            debugShowCheckedModeBanner: false,
            themeMode: app.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const PhoneLoginScreen(),
          );
        },
      ),
    );
  }
}
