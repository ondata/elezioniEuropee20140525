# Introduzione

In questo repository uno [script bash](./europee.sh) per scaricare i dati dell'"Area Italia" sulle **elezioni europee** del **25/05/2014** da questo sito: [https://elezionistorico.interno.gov.it/index.php?tpel=E&dtel=25/05/2014&tpa=I&tpe=A&lev0=0&levsut0=0&es0=S&ms=S](https://elezionistorico.interno.gov.it/index.php?tpel=E&dtel=25/05/2014&tpa=I&tpe=A&lev0=0&levsut0=0&es0=S&ms=S)

# Note

- **non è stata ancora fatta una revisione della bontà del risultato**;
- la cartella "elaborazioni" contiene i dati "puliti";
- la cartella "download" i dati "grezzi";
  - i file che iniziano con `l` sono quelli relativi alle liste;
  - i file che iniziano con `s` sono quelli relativi agli scrutini;
- nei CSV di _output_ è stata aggiunta una colonna `nomefile` (che essenzialmente il nome della provincia così come scritto sul sito di origine) che può essere utile per operazioni di _merge_, per comuni con nomi uguali, ecc.;
- al momento non sono stati aggiungi i codici ISTAT dei comuni;
- l'_encoding_ dei CSV è `UTF-8` e il separatore è la `,`.

# File

Due i file principali:

- [liste.csv](./elaborazioni/liste.csv), con il merge di tutti i dati sulle liste;
- [scrutini.csv](./elaborazioni/scrutini.csv), con il merge di tutti i dati sugli scrutini.

# Licenza sui dati

È la [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).