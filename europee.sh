#!/bin/bash

### requisiti ###
# scrape-cli https://github.com/aborruso/scrape-cli/releases
# Miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="https://elezionistorico.interno.gov.it/"

mkdir -p "$folder"/download


# circoscrizioni
curl 'https://elezionistorico.interno.gov.it/index.php?tpel=E&dtel=25/05/2014&tpa=I&tpe=A&lev0=0&levsut0=0&es0=S&ms=S' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.75 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'  -H 'Accept-Encoding: gzip, deflate, br'   --compressed | scrape -be '//div[@id="collapseFour"]//div[@class="sezione"]/ul[@class="nav"]/li/a' | xq -r '.html.body.a[]["@href"]' >"$folder"/download/00.txt

# regioni
rm "$folder"/download/01.txt
while read p; do
  curl "https://elezionistorico.interno.gov.it/$p" -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.75 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'  -H 'Accept-Encoding: gzip, deflate, br'   --compressed  | scrape -be '//div[@id="collapseFive"]//div[@class="sezione"]/ul[@class="nav"]/li/a' | xq -r '.html.body.a[]["@href"]' >>"$folder"/download/01.txt
done <"$folder"/download/00.txt

# provincia
rm "$folder"/download/02.tsv
while read p; do
  curl "https://elezionistorico.interno.gov.it/$p" -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.75 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'  -H 'Accept-Encoding: gzip, deflate, br'   --compressed  | scrape -be '//div[@id="collapseSix"]//div[@class="sezione"]/ul[@class="nav"]/li/a' | xq -r '.html.body.a[]|[.["#text"],.["@href"]]|@tsv' >>"$folder"/download/02.tsv
done <"$folder"/download/01.txt

# download dati
rm "$folder"/download/03.json
while IFS=$'\t' read -r col1 col2
do
    curl "https://elezionistorico.interno.gov.it/$col2" -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.75 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'  -H 'Accept-Encoding: gzip, deflate, br'   --compressed | scrape -be '//div[a[@href="#collapseSeven"]]' | xq -r '.html.body.div.a|{provincia:"'"$col1"'",URLscrutini:.[1]["@href"],URLliste:.[2]["@href"]}' >>"$folder"/download/03.json
done < "$folder"/download/02.tsv

mlr --j2n --ofs "\t" cat "$folder"/download/03.json  >"$folder"/download/03.tsv

while IFS=$'\t' read -r col1 col2 col3
do
    curl "https://elezionistorico.interno.gov.it/$col2" -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.75 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'  -H 'Accept-Encoding: gzip, deflate, br'   --compressed >"$folder"/download/s_"$col1".csv
    curl "https://elezionistorico.interno.gov.it/$col3" -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.75 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'  -H 'Accept-Encoding: gzip, deflate, br'   --compressed >"$folder"/download/l_"$col1".csv
done < "$folder"/download/03.tsv

# crea copia file
cp -rf "$folder"/download "$folder"/elaborazioni

# rimuovi righe vuote
sed -i '/^$/d' "$folder"/elaborazioni/*_*.csv

# rimuovi separatori errati
sed -i -r 's/;;$/;/g;s/;$//g' "$folder"/elaborazioni/l_*.csv
sed -i -r 's/;$//g' "$folder"/elaborazioni/s_*.csv

# rimuovi spazi bianchi inutili e cambia separatore
mlr -I --csv --ifs ";" --ofs "," clean-whitespace "$folder"/elaborazioni/*_*.csv

# aggiungi colonna nomefile
cd "$folder"/elaborazioni/
mlr -I --csv put '$nomefile=FILENAME' ./*_*.csv
sed -i -r 's|\./||g;s|\.csv||g;s|[ls]_||g' ./*_*.csv

# fai il merge
cd "$folder"
mlr --csv unsparsify "$folder"/elaborazioni/l_*.csv >"$folder"/elaborazioni/liste.csv
mlr --csv unsparsify "$folder"/elaborazioni/s_*.csv >"$folder"/elaborazioni/scrutini.csv