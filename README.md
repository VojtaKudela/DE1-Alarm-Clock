# DE1-Alarm Clock

1. Lukáš Katrňák (zodpovědný za obsluhu sedmisegmentového displeje)
2. Vojtěch Kudela (zodpovědný za řízení hodin)
3. Jan Jaroslav Koláček (zodpovědný za obsluhu alarmu)

### Blokové schéma Alarm Clock
![Alarm Clock](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/Alarm_clock.drawio%20(1).png).

### Inputs and Outputs

| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| **clk** | Input | 1 | Systémový hodinový signál 100 MHz |
| **btnu** | Input | 1 | Tlačítko nahoru (nastavení/zvyšování času hodin a alarmů) |
| **btnd** | Input | 1 | Tlačítko dolů (nastavení/snižování času hodin a alarmů) |
| **btnl** | Input | 1 | Tlačítko doleva (přechod mezi módy - hodiny/alarm) |
| **btnr** | Input | 1 | Tlačítko doprava (přechod mezi nastavováním HH a MM) |
| **btnc** | Input | 1 | Tlačítko střední (nastavování / potvrzování - podržení min. 2s) |
| **sw[2:0]** | Input | 3 | Vypínače sloužící k zapnutí a vypnutí jednotlivých budíků |
| **an[7:0]** | Output | 8 | Řízení aktivní anody 8místného sedmisegmentového displeje |
| **seg[6:0]** | Output | 7 | Řízení jednotlivých segmentů (katod A-G) displeje |
| **dp** | Output | 1 | Desetinná tečka displeje (indikace sekund) |
| **led[16:0]** | Output | 17 | Indikace stavu budíku on/off (LED 0:2) a signalizace zvonění |
| **buzz_out** | Output | 1 | Výstup pro zvukový generátor signálu (bzučák) |

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

## Hardwarový popis a demo aplikace

### Náhled na zařízení

### Top level

## Sofwarový popis

### Display
O zobrazování dat na 8místném sedmisegmentovém displeji desky Nexys A7 se stará modul `driver_7seg_8digits`. Aby bylo dosaženo rozsvícení všech 8 cifer "najednou", využívá se principu rychlého multiplexování. Cifry se střídají každé 2 milisekundy, což lidské oko díky setrvačnosti vnímá jako souvislý obraz.

Řízení displeje je rozděleno do tří hlavních strukturálních bloků:

1. **`clk_en` (Generátor povolovacího pulzu):**
   Bere systémový hodinový signál (100 MHz) a funguje jako dělička frekvence. Každé 2 milisekundy (500 Hz) vygeneruje jeden krátký povolovací pulz (`en`), který dává pokyn k přepnutí na další cifru.

2. **`cnt_up_down` (Čítač / Ukazatel adresy):**
   Tříbitový synchronní čítač, který přijímá pulzy z `clk_en`. Neustále odpočítává v rozsahu od 7 do 0. Jeho aktuální hodnota slouží jako adresa, která říká nadřazenému multiplexoru, která z 8 cifer má být v danou chvíli fyzicky aktivní (rozsvícená).

3. **`bin2seg` (Převodník / Dekodér znaků):**
   Kombinační obvod, který funguje jako překladový slovník. Přijímá 5bitový datový signál a okamžitě ho převádí na 7bitový vektor pro jednotlivé segmenty (A-G) displeje. Obsahuje logiku pro číslice 0-9 a speciální znaky (A, L, _, C, S, atd.) potřebné pro navigaci v menu budíku.

#### Architektura a princip multiplexování
Samotný `driver_7seg_8digits` všechny tyto moduly propojuje a obsahuje centrální **multiplexor**. Ten sleduje aktuální hodnotu z čítače a na jejím základě provede tři akce současně:
* Vybere správná 5bitová data ze vstupů (od nadřazeného hodinového modulu) a pošle je do dekodéru `bin2seg`.
* Nastaví logickou "0" na příslušný pin sběrnice `AN` (Anody), čímž zapne napájení pouze pro konkrétní cifru na desce (běžící nula).
* Vyhodnotí, zda má na dané pozici svítit desetinná tečka (`dp_o`), která v projektu slouží k indikaci plynoucích sekund (blikání 1 Hz) mezi hodinami a minutami.

#### Blokové schéma řízení displeje
<img src="Images/driver_7seg_8digits.png" alt="Schéma driveru" width="750">

### Nastavovíní hodin a budíku

### Alarm

## Instrukční návod

### Popis částí

### Nastavení času

### Video ukázka

## Co udělat do projektu

- [x] Nahrát blokové schéma projektu
- [ ] nahrát soubor XDC -> co budeme používat

### Hodiny
- [ ] vytvoření 1Hz generátoru
- [ ] vytvoření generátor hodinového signálu a čítače, pomocí kterého se následně bude zobrazovat čas 

### Displej
- [x] vytvořit převodní tabulku pro symboly
- [x] vytvořit řízení 7 segmentu (zobrazení symbolů) a jednotlivých anod segmentů (přepínání 2ms)
- [x] tečka mezi HH a MM bude představovat sekundy (bude blikat)
- [ ] blikání, pokud bude docházet k nastavování času hodin nebo alarmu (MM bliká, pokud nastavuji HH a naopak) -> možná vynecháme

### Tlačítka
- [ ] vytvoření stavového automatu pro jejich ovládání
- [ ] nastavení času (BTNU a BTND), přecházení mezi módy (hodiny a alarm) (BNTL a BNTR) + přechod při nastavování času (HH:MM) a pomocí prostředního (BTNC) bude docházet k nastavení (SET)/ potvrzování

### Alarm
- [ ] nastavení času se zvukovým výstupem (přiřazení periferie) a světelnou signalizací pomocí LED nad switchy
- [ ] nastavení zapnutí/ vypnutí alarmu -> LED bude reprezentovat tyto stavy
- [x] vytvořit generátor signálu, který bude posílán na bzučák
- [x] vytvoření paměti s alarmy

## REFERENCE
1. [Online VHDL Testbench Template Generator (lapinoo.net)](https://vhdl.lapinoo.net/testbench/).
2. [DATASHEET for Pasive Buzzer HW-508 V0.2](https://digizone.com.ve/wp-content/uploads/2022/03/KY-006-Joy-IT.pdf).
3. [Vytváření diagramů draw.io](https://www.drawio.com/).

### Pomoc s Githubem
4. [Jak upravovat README](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).
5. [Vytvoření složky](https://www.youtube.com/watch?v=FvCsnUgAdWA).
6. [Jak nahrát soubor](https://www.youtube.com/watch?v=ATVm6ACERu8).
