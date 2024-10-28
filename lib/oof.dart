import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<void> connect() async {
    // Indica l'host del broker MQTT, ad esempio un IP o un dominio
    client = MqttServerClient('test.mosquitto.org', '');

    // Configura il client
    client.port = 1883; // Default MQTT port
    client.keepAlivePeriod = 20;
    client.logging(on: false);

    // Gestisci i callback per la connessione, la disconnessione, e la ricezione dei messaggi
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = (topic) {
      print('Errore nella sottoscrizione al topic $topic');
    };
    client.pongCallback = () {
      print('Ping ricevuto dal broker MQTT');
    };

    try {
      print('Connettendo al broker MQTT...');
      final connResult = await client.connect();
      if (connResult?.state != MqttConnectionState.connected) {
        print('Connessione fallita, stato: ${connResult?.state}');
        client.disconnect();
        return;
      }
    } catch (e) {
      print('Errore durante la connessione: $e');
      client.disconnect();
      return; // Esci se la connessione fallisce
    }

    // Sottoscriviti a un topic solo se la connessione è stabilita
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Sottoscrivendo al topic...');
      client.subscribe('invioCasuale', MqttQos.atLeastOnce);
    } else {
      print('Connessione non stabilita, impossibile sottoscrivere');
      return;
    }

    // Verifica se client.updates è null
    if (client.updates == null) {
      print('client.updates è null, impossibile ricevere messaggi.');
      return;
    }

    // Ricezione dei messaggi
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      print('Ricevuto un aggiornamento: $c');
      if (c != null && c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print('Messaggio ricevuto: $pt');
      } else {
        print('Nessun messaggio ricevuto o lista vuota.');
      }
    });
  }

  void onConnected() {
    print('Connesso al broker MQTT');
  }

  void onDisconnected() {
    print('Disconnesso dal broker MQTT');
  }

  void onSubscribed(String topic) {
    print('Sottoscritto al topic: $topic');
  }

  void disconnect() {
    client.disconnect();
  }
}
