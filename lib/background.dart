import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:audioplayers/audioplayers.dart';

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
      client.subscribe('test', MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> message) {
        final recMess = message[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print('Received message: ${payload} from topic: ${message[0].topic}');

        // Riproduci il suono quando ricevi un messaggio
        audioPlayer.play(AssetSource('alert_sound.mp3'));
        print("sound");
        print(AssetSource('alert_sound.mp3').toString());
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
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

void onSubscribed(String topic) {
  print('EXAMPLE::OnSubscribed callback with topic: $topic');
}

void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnected');
}

// La funzione playNotification non è necessaria qui
