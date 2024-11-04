import 'package:flutter/material.dart';
import 'package:flutter_application_1/background.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Crea una mappa per salvare i diversi errori: suddivisi per motivo,
  // categoria e item.
  Map<String, dynamic> errors = {};

  errors['reason'] = [
    'Camera not connected',
    'Guider not connected',
    'Dither failed to execute'
  ];

  errors['category'] = '';
  errors['item'] = ['Dither failed to execute'];

  print(errors.toString());

  SharedPreferences.getInstance().then((value) {
    value.setString('ip', 'test.mosquitto.org');
    value.setInt('port', 1883);
    value.setString('topic', 'test');
    value.setString('details', errors.toString());
    // Salva le preferenze convertendo gli errori in un simil JSON.
  });

  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Background Service')),
      body: Center(child: Text('Service is running in the background')),
    );
  }
}
