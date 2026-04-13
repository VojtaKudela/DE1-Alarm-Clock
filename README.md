# DE1-Alarm Clock

1. Lukáš Katrňák (zodpovědný za obsluhu sedmisegmentového displeje)
2. Vojtěch Kudela (zodpovědný za řízení hodin)
3. Jan Jaroslav Koláček (zodpovědný za obsluhu alarmu)

### Blokové schéma Alarm Clock
![Alarm Clock](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/Alarm%20Clock.drawio.png).

### Popis jednotlivých periferií 
_**Vstupní perifirie**_
- CLK 100MHz -> vstupné hodinový tak, pro řízení hodin
- BTNU a BTND -> tlačítka pro nastavení šasu hodin  alarmů
- BTNL a BTNR -> přechod mezi módy a mezi HH a MM při nastavování času
- BTNC -> slouží k **nastavoání/potvrzování** (k nastavení dojde, pokud bude stlačeno po dobu minimálně 2 sekund)
- SW [0:3] -> vypínače slouží k zapnití a vypnutí budíku

_**Výstupní perifirie**_
- AN [7:0] -> slouží k řízení anod sedmisegmentového displeje
- SEG [6:0] -> řízení jednotlivých segmentů každého sedmisegmentového displeje
- BUZZER -> řízení alarmu (přiřadit periferii)
- LED_OUT [0:15] -> 3 LED nad switchy představují indikaci stavu budíku **on/off** (LED 0:2) a zbylé budou sloužit jako signalizace budíku (budou spuštěny ve stejný moment, kdy se spustí alarm)


## Co udělat do projektu

- [x] Nahrát blokové schéma projektu
- [ ] nahrát soubor XDC -> co budeme používat

### Hodiny
- [ ] vytvoření 1Hz generátoru
- [ ] vytvoření generátor hodinového signálu a čítače, pomocí kterého se následně bude zobrazovat čas 

### Displej
- [ ] vytvořit převodní tabulku pro symboly
- [ ] vytvořit řízení 7 segmentu (zobrazení symbolů) a jednotlivých anod segmentů (přepínání 2ms)
- [ ] tečka mezi HH a MM bude předtavovat sekundy (bude blikat)
- [ ] blikání, pokud bude docházet k nastavování času hodin nebo alarmu (MM bliká, pokud nastavuji HH a naopak)

### Tlačítka
- [ ] vytvoření stavového automatu pro jejich ovládání
- [ ] nastavení času (BTNU a BTND), přecházení mezi módy (hodiny a alarm) (BNTL a BNTR) + přechod při nastavování času (HH:MM) a pomocí prostředního (BTNC) bude docházet k nastavení (SET)/ potvrzování

### Alarm
- [ ] nastavení času se zvukovým výstupem (přiřazení periferie) a světelnou signalizací pomocí LED nad switchy
- [ ] nastavení zapnutí/ vypnutí alarmu -> LED bude reprezentovat tyto stavy
- [ ] vytvořit generátor signálu, který bude posílán na bzučák
- [ ] vytvoření paměti s alarmy

## Pomoc s Githubem
1. [Jak upravovat README](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).
2. [Vytvoření složky](https://www.youtube.com/watch?v=FvCsnUgAdWA).
3. [Jak nahrát soubor](https://www.youtube.com/watch?v=ATVm6ACERu8).

## REFERENCE
1. [Online VHDL Testbench Template Generator (lapinoo.net)](https://vhdl.lapinoo.net/testbench/).
2. [DATASHEET for Pasive Buzzer HW-508 V0.2](https://digizone.com.ve/wp-content/uploads/2022/03/KY-006-Joy-IT.pdf).
3. [Vytváření diagramů draw.io](https://www.drawio.com/).
