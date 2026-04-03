# DE1-Alarm Clock

1. Lukáš Katrňák ()
2. Vojtěch Kudela ()
3. Jan Jaroslav Koláček ()

### Blokové schéma Alarm Clock
![Alarm Clock](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/Diagram%20Alarm%20Clock.jpg).

## Co udělat do projektu

- [ ] Nahrát blokové schéma projektu
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
- [ ] nastavení času (BTNU a BTND), přecházení mezi hodinami a alarmem (BNTL a BNTR) a pomocí prostředního (BTNC) bude docházet k nastavení (SET)

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
