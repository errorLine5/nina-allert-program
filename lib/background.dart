import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onForegroundIos,
      onBackground: onBackgroundIos,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    final client = MqttServerClient('test.mosquitto.org', '');

    // Configura il client
    client.port = 1883; // Default MQTT port
    client.keepAlivePeriod = 20;
    client.logging(on: true);
    client.setProtocolV311();

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = (topic) {
      print('Errore nella sottoscrizione al topic $topic');
    };
    client.pongCallback = () {
      print('Ping ricevuto dal broker MQTT');
    };

    client.connect();
  }

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Running background service",
      );
    }

    service
        .invoke('update', {"current_time": DateTime.now().toIso8601String()});

    //every 15 seconds print the current time
    print(DateTime.now().toIso8601String());
  });
}

@pragma('vm:entry-point')
bool onForegroundIos(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print("onForegroundIos");
  return true;
}

bool onBackgroundIos(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print("onBackgroundIos");
  return true;
}

void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

void onSubscribed(String topic) {
  print('EXAMPLE::OnSubscribed callback with topic: $topic');
}

void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnected');
}
