# IncluDO-Project
📌# Introduzione

Questo progetto consiste in uno smart contract di e-commerce sviluppato in Solidity, con l'obiettivo di gestire la vendita di prodotti digitali su blockchain. Il contratto principale, CourseCommerceManager, si affianca alla libreria SalesUtils per gestire operazioni legate alle vendite, ai clienti e all'analisi delle transazioni. L'intero sistema è pensato per essere modulare, leggibile e facilmente integrabile in ambienti decentralizzati.

📁# Struttura del progetto

Il progetto è suddiviso in due componenti principali: il contratto CourseCommerceManager.sol, che gestisce direttamente la logica applicativa dell'e-commerce (aggiunta prodotti, acquisti, prelievi ecc.), e la libreria SalesUtils.sol, che fornisce funzioni ausiliarie per analizzare e organizzare i dati di vendita. Questa suddivisione è stata pensata per migliorare la manutenibilità del codice e la separazione delle responsabilità.

⚙️ #Scelte progettuali

Durante lo sviluppo, si è scelto di implementare una libreria esterna per delegare le funzionalità più complesse, come il calcolo delle vendite per periodo o l’estrazione degli acquisti di un determinato utente. Questo approccio favorisce il riutilizzo del codice, la modularità e l’isolamento della logica di business. Inoltre, il contratto principale è stato progettato per essere trasparente e tracciabile: ogni azione significativa (aggiunta prodotto, acquisto, prelievo) è associata a un evento che può essere ascoltato da strumenti esterni come Etherscan o frontend personalizzati.

Tutte le strutture dinamiche come gli array e le stringhe sono gestite in memory, come richiesto dalla sintassi di Solidity, e vengono utilizzati modificatori di sicurezza per verificare l’esistenza di prodotti e vendite prima di eseguire funzioni che li utilizzano. Il controllo degli accessi è garantito attraverso il modificatore onlyOwner, che protegge le funzioni critiche dall’uso non autorizzato.

Le funzioni receive() e fallback() sono incluse per garantire che il contratto possa ricevere Ether anche in caso di chiamate dirette o errate, aumentando la robustezza del sistema.

🔧# Funzionalità del contratto

Il contratto consente all’amministratore di aggiungere nuovi prodotti specificando nome, indirizzo e prezzo in Ether (convertito in Wei per la gestione interna). Gli utenti possono acquistare i prodotti inviando il valore esatto, o superiore, rispetto al prezzo; in quest’ultimo caso, l’eccesso viene rimborsato. È possibile per l’owner prelevare l’intero saldo o un ammontare specifico attraverso funzioni dedicate.

Sono presenti inoltre funzioni per accedere ai dettagli dei prodotti, alle vendite registrate, e alle informazioni relative agli acquisti effettuati da un determinato utente. Grazie alla funzione getSalesInPeriod, l’owner può anche analizzare l’ammontare delle vendite generate in un intervallo temporale specificato attraverso timestamp UNIX. Per facilitare l’integrazione con frontend e dashboard, è disponibile anche getAllProducts, che restituisce una panoramica completa dei prodotti registrati.

La funzione weiToEther permette di convertire importi da Wei a Ether, ma data la mancanza di supporto per numeri decimali in Solidity, i valori restituiti sono troncati. Per una rappresentazione più precisa, si consiglia di effettuare questa conversione lato frontend.

🔐 #Sicurezza e controllo degli accessi

Il contratto adotta misure di sicurezza fondamentali per un ambiente decentralizzato. Il controllo degli accessi è centrale: solo l’indirizzo del proprietario può eseguire operazioni critiche come aggiungere prodotti o prelevare fondi. Questo è garantito dal modificatore onlyOwner. Inoltre, prima di eseguire operazioni su prodotti o vendite, viene verificata la loro esistenza tramite i modificatori productExists e saleExists, evitando accessi fuori dai limiti degli array.

Tutte le transazioni finanziarie sono protette da controlli di validità, come ad esempio il controllo sull’ammontare da prelevare o il prezzo minimo per effettuare un acquisto. La presenza di eventi per ogni azione rilevante garantisce una tracciabilità completa e pubblica, elemento essenziale per il monitoraggio e la trasparenza in ambienti blockchain.

Le funzioni receive() e fallback() assicurano che il contratto non perda fondi in caso di chiamate anomale, aumentando la tolleranza agli errori e l’interoperabilità con altri smart contract o wallet.

⛽# Costi di gas

Il contratto è stato progettato con attenzione anche all’efficienza in termini di gas. Le operazioni più costose, come l’iterazione su array per il calcolo delle vendite o degli acquisti di un cliente, sono eseguite tramite funzioni view e pure, senza scrittura su blockchain. Questo consente un’esecuzione a basso costo o addirittura gratuita lato frontend.

Le funzioni che comportano scrittura su blockchain, come purchaseProduct o addProduct, sono ottimizzate evitando duplicazioni o operazioni inutili. Ad esempio, l’eccesso di pagamento viene rimborsato in modo diretto senza chiamate esterne costose. Tuttavia, l’uso di array dinamici può incidere leggermente sui costi in caso di dataset molto grandi; in un contesto di produzione su larga scala, sarebbe utile integrare una struttura indicizzata o un mapping.

In generale, le scelte fatte consentono di mantenere bassi i costi operativi per gli utenti e per l’amministratore, preservando al contempo flessibilità e funzionalità.

📌 #Conclusione

Questo progetto dimostra un'applicazione concreta e solida degli smart contract in ambito e-commerce. L'uso di una libreria esterna migliora l’organizzazione e la manutenibilità del codice. Le funzionalità offerte permettono di gestire con facilità il ciclo di vita di un prodotto, di effettuare vendite tracciabili e di analizzare i dati relativi al comportamento dei clienti. L'infrastruttura è pensata per essere integrata con un frontend React o con strumenti di monitoraggio on-chain, risultando versatile e pronta per l’adozione reale in un contesto decentralizzato.
