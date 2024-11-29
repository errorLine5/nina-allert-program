import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global variables to store MQTT connection settings
String ipAddress = '';
String topic = '';
String port = '1883';
String csvtags = '';

// Flag to control audio alert playback
bool shouldPlaySound = false;

/// Initializes and configures the background service
/// Returns the configured FlutterBackgroundService instance
Future<FlutterBackgroundService> initializeService() async {
  print('initializeService');

  final service = FlutterBackgroundService();
  WidgetsFlutterBinding.ensureInitialized();

  // Configure platform-specific background service settings
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // Main background service function for Android
      isForegroundMode: true, // Run as foreground service to avoid being killed
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onForegroundIos,
      onBackground: onBackgroundIos,
    ),
  );

  // Load saved settings from SharedPreferences
  await SharedPreferences.getInstance().then((prefs) {
    ipAddress = prefs.getString('ipAddress') ?? '';
    topic = prefs.getString('topic') ?? '';
    port = prefs.getString('port') ?? '';
    csvtags = prefs.getString('csvtags') ?? '';

    // Set default values if no saved settings exist
    if (ipAddress == '' || topic == '' || port == '' || csvtags == '') {
      ipAddress = 'test.mosquitto.org';
      topic = 'test';
      port = '1883';
      csvtags = 'camera,mount,focuser';
    }
  });

  await service.startService();
  return service;
}

/// Main background service function for Android
/// Handles MQTT connection and message processing
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    // Listen for stop service command
    service.on('stopService').listen((event) {
      print('stopService');
      service.stopSelf();
    });

    // Listen for silence command to stop audio alerts
    service.on('silence').listen((event) {
      print('silence');
      shouldPlaySound = false;
    });

    // Load settings from SharedPreferences
    await SharedPreferences.getInstance().then((prefs) {
      ipAddress = prefs.getString('ipAddress') ?? 'test.mosquitto.org';
      topic = prefs.getString('topic') ?? 'test';
      port = prefs.getString('port') ?? '1883';
      csvtags = prefs.getString('csvtags') ?? 'camera,mount,focuser';
    });

    print('ipAddress: $ipAddress');
    print('topic: $topic');
    print('port: $port');
    print('csvtags: $csvtags');

    // Initialize MQTT client and audio player
    final client = MqttServerClient(ipAddress, '');
    final AudioPlayer audioPlayer = AudioPlayer();

    // Configure MQTT client settings
    client.port = int.parse(port);
    client.keepAlivePeriod = 20; // Keep-alive interval in seconds
    client.logging(on: true);
    client.setProtocolV311(); // Use MQTT protocol version 3.1.1

    // Set up MQTT event callbacks
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = (topic) {
      print('Errore nella sottoscrizione al topic $topic');
    };

    // Connect to MQTT broker and subscribe to topic
    client.connect().then((value) {
      print('subscribe to $topic');
      client.subscribe(topic, MqttQos.atLeastOnce);

      // Create periodic timer for sound alerts
      Timer.periodic(const Duration(seconds: 3), (timer) {
        if (shouldPlaySound) {
          audioPlayer.play(AssetSource('alert_sound.mp3'), volume: 10);
        }
      });

      // Listen for MQTT messages
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> message) {
        final recMess = message[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        // Check if message contains any monitored tags
        if (csvtags.isNotEmpty) {
          if (csvtags.contains(',')) {
            final tags = csvtags.split(',');
            for (String tag in tags) {
              if (tag.trim().isNotEmpty && payload.contains(tag.trim())) {
                shouldPlaySound = true;
              }
            }
          } else {
            if (csvtags.trim().isNotEmpty && payload.contains(csvtags.trim())) {
              shouldPlaySound = true;
            }
          }
        }

        // Play alert sound if triggered
        if (shouldPlaySound) {
          audioPlayer.play(AssetSource('alert_sound.mp3'));
        }

        // Process message content and send appropriate error to UI
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
  }
}

/// iOS foreground service handler
@pragma('vm:entry-point')
bool onForegroundIos(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print("onForegroundIos");
  return true;
}

/// iOS background service handler
bool onBackgroundIos(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print("onBackgroundIos");
  return true;
}

/// MQTT connection callback
void onConnected() {
  print("onConnected $ipAddress");
}

/// MQTT subscription callback
void onSubscribed(String topic) {
  print('onSubscribed $topic');
}

/// MQTT disconnection callback
void onDisconnected() {
  print('onDisconnected');
}

/// Service stop callback
void onStopService() {
  print('onStopService');
}
