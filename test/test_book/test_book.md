procedure di testing

L'applicazione deve essere in grado di:

Ricevere errori dal software di gestione del telescopio.
Elaborare gli errori e attivare un suono di allarme in caso di errore.
Consentire all'utente di spegnere l'allarme tramite un pulsante.


TEST 1: Attivazione dell'Alert Sonoro su Errore

bisogna Verificare che l'applicazione emetta un suono di allarme quando riceve un errore dal software del telescopio.

CONDIZIONI DI TEST
------------------
1)Simulare la ricezione di un errore dal software del telescopio.
2)L'applicazione deve rilevare l'errore e attivare l'allarme.

PASSI
-----------------
1)Simulare un errore proveniente dal software del telescopio.
2)L'applicazione deve chiamare una funzione per emettere l'alert.

RISULTATO PREVISTO

Il suono di allarme deve essere attivato una volta che l'errore è stato rilevato.

TEST 2: Spegnimento dell'Alert Sonoro tramite Pulsante

SCOPO
-----------------
Verificare che l'utente possa spegnere il suono dell'allarme tramite un pulsante designato.

CONDIZIONI DI TEST
-----------------
1)L'applicazione deve avere un alert attivo.
2)L'utente deve cliccare sul pulsante per spegnere l'allarme, l'allarme non deve spegnersi da solo.

PASSI
-----------------
1)Impostare lo stato dell'applicazione come se l'alert fosse attivo.
2)Simulare il clic dell'utente sul pulsante "stop".
3)L'applicazione deve chiamare una funzione per spegnere l'alert e aggiornare lo stato dell'alert a False.

RISULTATO ATTESO
-----------------
Il suono dell'allarme deve essere disattivato e lo stato dell'alert deve passare da True a False.

TEST 3: se non ci sono errori, l'alert non deve partire

SCOPO
-----------------
Verificare che l'applicazione non attivi l'allarme se non riceve un messaggio di errore.

CONDIZIONI DI TEST
-----------------
1)L'applicazione riceve un messaggio che non contiene errori.
2)l'alert deve rimanere spento.

PASSI
-----------------
1)Simulare la ricezione di un messaggio qualsiasi ma non di errore.
2)Verificare che la funzione che richiama l'alert non venga chiamata.

RISULTATO ATTESO
-----------------
Nessun suono di allarme deve essere emesso.

TEST 4: Gestione di Multipli Errori

SCOPO
-----------------
Verificare che l'applicazione gestisca correttamente la ricezione di più errori in successione.

CONDIZIONI DI TEST
-----------------
1)L'applicazione riceve più errori uno dopo l'altro.

PASSI
-----------------
1)Simulare la ricezione di due errori consecutivi.
1)Verificare che l'allarme sia attivato per ogni errore.

RISULTATO ATTESO
-----------------
L'applicazione deve emettere un alert per ogni errore ricevuto senza sovrapposizioni di suoni o malfunzionamenti.
inoltre per spegnere gli alert devo poter attivare solo una volta il pulsante, ma mi devono apparire tutti gli errori che hanno causato l'attivazione dell'alert.

