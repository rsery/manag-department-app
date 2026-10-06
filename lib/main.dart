import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:manag_department_software_2/screenes/login_screen.dart';
import 'package:manag_department_software_2/services/app_update_service.dart';
import 'package:manag_department_software_2/shared/shared_data.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedData.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppStartup(),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  final AppUpdateService _updateService = AppUpdateService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  Future<void> _checkForAppUpdate() async {
    if (!mounted) {
      return;
    }

    await _updateService.checkAndShowUpdateDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}