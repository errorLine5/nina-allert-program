import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

String ipAddress = '';
String topic = '';
String port = '1883';

Future<FlutterBackgroundService> initializeService() async {
  print('initializeService');

  final service = FlutterBackgroundService();
  WidgetsFlutterBinding.ensureInitialized();

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

  await SharedPreferences.getInstance().then((prefs) {
    ipAddress = prefs.getString('ipAddress') ?? '';
    topic = prefs.getString('topic') ?? '';
    port = prefs.getString('port') ?? '';

    if (ipAddress == '' || topic == '' || port == '') {
      ipAddress = 'test.mosquitto.org';
      topic = 'test';
      port = '1883';
    }
  });
  await service.startService();
  return service;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      print('stopService');
      service.stopSelf();
    });

    await SharedPreferences.getInstance().then((prefs) {
      ipAddress = prefs.getString('ipAddress') ?? 'test.mosquitto.org';
      topic = prefs.getString('topic') ?? 'test';
      port = prefs.getString('port') ?? '1883';
    });

    print('ipAddress: $ipAddress');
    print('topic: $topic');
    print('port: $port');

    final client = MqttServerClient(ipAddress, '');
    final AudioPlayer audioPlayer = AudioPlayer(); // Instanza AudioPlayer qui

    // Configura il client
    client.port = 1883; // Default MQTT port
    client.keepAlivePeriod = 20; // TTL
    client.logging(on: true); // ??
    client.setProtocolV311(); //

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;

    client.onSubscribeFail = (topic) {
      print('Errore nella sottoscrizione al topic $topic');
    };

    client.connect().then((value) {
      print('subscribe to $topic');
      client.subscribe(topic, MqttQos.atLeastOnce);
      SharedPreferences.getInstance().then((prefs) {
        client.updates!
            .listen((List<MqttReceivedMessage<MqttMessage>> message) {
          final recMess = message[0].payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          // Riproduci il suono quando ricevi un messaggio
          audioPlayer.play(AssetSource('alert_sound.mp3'));
          print("sound");
          print(AssetSource('alert_sound.mp3').toString());

          // Send error directly to UI through background service
          if (payload.contains('camera')) {
            print('camera');
            service.invoke('updateErrors', {
              'icon': 'camera',
              'object': 'Camera has problems',
              'content': payload
            });
          } else if (payload.contains('mount')) {
            print('mount');
            service.invoke('updateErrors', {
              'icon': 'mouse',
              'object': 'Mount has problems',
              'content': payload
            });
          } else if (payload.contains('focuser')) {
            print('focuser');
            service.invoke('updateErrors', {
              'icon': 'radar',
              'object': 'Focuser has problems',
              'content': payload
            });
          } else {
            print('unknown');
            service.invoke('updateErrors', {
              'icon': 'error_outline',
              'object': 'Unknown error',
              'content': payload
            });
          }
        });
      });
    });
  }
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
  print("ipAddress: $ipAddress");
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

void onSubscribed(String topic) {
  print('EXAMPLE::OnSubscribed callback with topic: $topic');
}

void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnected');
}

void onStopService() {
  print('EXAMPLE::OnStopService client callback - Client stopped');
}

// La funzione playNotification non è necessaria qui
