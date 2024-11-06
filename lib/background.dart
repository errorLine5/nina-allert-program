import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// initializeService contiene la definizione del comportamento
/// dell'applicazione all'avvio, nonchè la definizione di un
/// oggetto FlutterBackgroundService per la gestione di un
/// servizio in background.
Future<void> initializeService() async {

  // Istanza necessaria per la gestione di un servizio in background.
  final service = FlutterBackgroundService();

  await service.configure(
    // Configurazione Android
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,       // comportamento all'avvio
      isForegroundMode: true, // impedisce la chiusura da parte del sistema
      autoStart: true,        // esecuzione all'avvio
    ),

    // Configurazione iOS
    iosConfiguration: IosConfiguration(
      // ! NON eliminare (obbligatoria per il funzionamento anche se
      // apparentemente inutile)
      onForeground: onForegroundIos,
      onBackground: onBackgroundIos,
    ),
  );
  service.startService();     // avvio del servizio in background
}

@pragma('vm:entry-point')     // entry-point della JVM

/// onStart si occupa di gestire la logica del servizio in background
/// dell'applicazione (creazione di un client, sottoscrizione ad un topic e
/// gestione dei messagi ricevuti).
void onStart(ServiceInstance service) {
  // Controlla che il servizio ricevuto sia istanza di un servizio
  // Android.
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();     // Arresta il servizio se necessario
    });

    // creazione di un clien MQTT
    final client = MqttServerClient('test.mosquitto.org', '');

    // Configurazione del client
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: true);
    client.setProtocolV311();
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = (topic) { print('Err. $topic'); };

    client.connect().then((value) {
      client.subscribe('test', MqttQos.atLeastOnce);
      // MqttQos.atLeastOnce si assicura che il messaggio arrivi
      // almeno una volta.

      // Ascolta i messaggi in arrivo sul topic
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> message) {
        // Casting del messaggio ricevuto di tipo MqttMessage in una delle
        // categorie di messaggi (in questo caso MqttPublishMessage).
        final recMess = message[0].payload as MqttPublishMessage;

        // Converte il messaggio ricevuto in una stringa.
        final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print('Received message: ${payload} from topic: ${message[0].topic}');
      });
    });
  }
}

// Ignorare > iOS
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
//---------------

/// onConnected contiene il codice eseguito nel momento in cui avviene la
/// connessione ad un broker MQTT.
void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

/// onSubscribed contiene il codice eseguito nel momento in cui avviene la
/// sottoscrizione ad un topic.
void onSubscribed(String topic) {
  print('EXAMPLE::OnSubscribed callback with topic: $topic');
}

/// onDisconnected contiene il codice eseguito nel momento in cui avviene la
/// disconnessione del client.
void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnected');
}