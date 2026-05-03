# DE1-Alarm Clock

1. Lukáš Katrňák (zodpovědný za obsluhu sedmisegmentového displeje)
2. Vojtěch Kudela (zodpovědný za řízení hodin a finální kompletaci)
3. Jan Jaroslav Koláček (zodpovědný za obsluhu alarmu a poster)

## Teoretický popis

Tento projekt se zaměřuje na realizaci plně funkčního digitálního budíku v jazyce VHDL. Cílem bylo vytvořit systém, který nejen přesně měří čas, ale také poskytuje pokročilé uživatelské rozhraní pro správu více budíků s funkcí odloženého buzení (Snooze). Návrh je postaven na principech synchronní číslicové techniky, modularity a efektivního využití hardwarových zdrojů.

### Blokové schéma Alarm Clock
![Alarm Clock](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/Blokov%C3%A9_sch%C3%A9ma_fina.drawio.png)

### Časová základna a hierarchické dělení kmitočtu
Základem každého digitálního chronometru je stabilní oscilátor. Vzhledem k tomu, že vnitřní hodiny FPGA pracují na vysoké frekvenci (typicky 100 MHz), tvoří první logickou vrstvu kódu generátor povolovacích pulzů (Clock Enable). Místo vytváření nových hodinových domén, které by mohly vést k problémům s časováním, systém využívá čítač, který každou sekundu vygeneruje jeden krátký pulz. Tento pulz slouží jako impuls pro hlavní čítač času, který v kaskádovém uspořádání inkrementuje vteřiny, minuty a hodiny v šestnáctkové či desítkové soustavě s příslušnými moduly (60 pro vteřiny a minuty, 24 pro hodiny).

### Ošetření vstupů a uživatelská interakce
Klíčovou výzvou při návrhu vestavěných systémů je interakce s reálným světem. Mechanická tlačítka trpí jevem zvaným kmity kontaktů (bouncing). V kódu je tento problém vyřešen modulem pro digitální filtraci, který vzorkuje stav tlačítka v delších intervalech a vyhodnotí stisk až po ustálení signálu. Navazující logika detekce hran zajišťuje, že každý stisk vyvolá právě jednu akci. Pro pokročilé ovládání, jako je vstup do editačního režimu, je implementován algoritmus pro měření délky stisku – tzv. Long Press logika, která vyžaduje podržení tlačítka po dobu 2 sekund.

### Dynamické řízení zobrazení a stavová logika
Pro zobrazení času je využit sedmisegmentový displej s technologií dynamického multiplexování. Aby se ušetřily vývody FPGA, jsou segmenty všech číslic propojeny a systém v rychlém sledu (řády stovek Hz) přepíná mezi jednotlivými pozicemi (anodami). Lidské oko díky setrvačnosti vnímá obraz jako statický. Celé chování systému – od běžného zobrazení času přes prohlížení tří nezávislých budíků až po jejich nastavování – je řízeno konečným stavovým automatem (FSM). Ten zaručuje, že se zařízení nachází vždy v definovaném stavu a správně reaguje na uživatelské podněty.

### Logika budíku a správa paměti
Systém obsahuje vnitřní paměťové registry pro uložení tří časů buzení. Komparační jednotka v každém hodinovém cyklu porovnává aktuální čas s časy v paměti. Pokud dojde ke shodě a daný budík je aktivován uživatelským přepínačem, dojde k aktivaci zvukového výstupu. Implementovaná funkce Snooze využívá pomocný čítač, který po stisku tlumicího tlačítka pozastaví alarm na přesně definovaný interval (5 minut), po jehož uplynutí se proces porovnávání a buzení automaticky restartuje.

## Hardwarový popis a demo aplikace
Zařízení bylo oživeno a testováno na desce **NEXY-A7-50T**. Tato deska obsahuje mimo jiné **osmimístný sedmisegmentový display**, **3 LED diody** a **5 tlačítek**, což jsou periferie, které byly užity. Další zařízení bylo připojeno na vnější port **buzzer**, tedy *(JA[1])*. Na ten byl připojen _**buzzer**_, který slouží k zvukové signalizaci, při spuštění alarmu.

![Náhled na zařízení](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/N%C3%A1hled.jpg)

## Popis jednotlivých periferií


| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| **clk** | Input | 1 | Systémový hodinový signál 100 MHz |
| **rst** | Input | 1 | Reset celých hodin provádějí se pomocí vypínače rst _**(sw15)**_ |
| **btnU** | Input | 1 | Tlačítko nahoru (nastavení/zvyšování času hodin a alarmů) |
| **btnD** | Input | 1 | Tlačítko dolů (nastavení/snižování času hodin a alarmů) |
| **btnL** | Input | 1 | Tlačítko doleva (přechod mezi módy - hodiny/alarm) |
| **btnR** | Input | 1 | Tlačítko doprava (přechod mezi nastavováním HH a MM) |
| **btnC** | Input | 1 | Tlačítko střední (nastavování / potvrzování - podržení min. 2s) |
| **sw0** | Input | 1 | Vypínač pro zapnutí/vypnutí budíku 1 |
| **sw1** | Input | 1 | Vypínač pro zapnutí/vypnutí budíku 2 |
| **sw2** | Input | 1 | Vypínač pro zapnutí/vypnutí budíku 3 |
| **an[7:0]** | Output | 8 | Řízení aktivní anody 8místného sedmisegmentového displeje |
| **seg[6:0]** | Output | 7 | Řízení jednotlivých segmentů (katod A-G) displeje |
| **dp** | Output | 1 | Desetinná tečka displeje (indikace plynoucích sekund) |
| **led[2:0]** | Output | 3 | Indikace stavu budíků on/off |
| **buzzer** | Output | 1 | Výstup pro zvukový generátor signálu (bzučák) |

### Top level

Blok [`top_alarm_clock`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/top_alarm_clock.vhd) je nejvyšší úrovní celého zařízení. Zde jsou utvořeny vývody pro jednotlivé periferie, které jsou poté přiřazeny pomocí contrainu. Vývody btnC, btnD, btnU, btnR a btnL jsou připojeny k jednotlivým tlačítkům na desce. Vývod led[2:0] je připojen k LED diodám na desce. Vývody CA, CB, CC, CD, CE, CF, CG, DP, AN[7:0] řídí sedmisegmentový display. Vývod CLK100MHZ potom je připojen na zdroj hodinových pulzů.

![TOP_LEVEL](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/TOP_ALARM_CLOCK.png)

## Sofwarový popis
Celé zařízení je možné si rozdělit do několika hlavních bloků: **TIME_CORE**, blok pro obsluhu displeje (např. **DISPLAY_DRIVER**) a generátorů časových základen (**CLOCK_ENABLE**). Každý z nich obsluhuje odlišnou část zařízení. 

### Nastavování hodin a budíku

Blok `time_core` představuje hlavní _**"mozek"**_ celého budíku. Je zodpovědný za udržování přesného času a řízení logiky uživatelského rozhraní. Modul je vnitřně rozdělen na dvě hlavní části, a to `time_counter` a `main_loop`. 

![TIME_CORE](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/TIME_CORE.png)

**1. Čítač času ([`time_counter`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/time_counter.vhd))**

Jedná se o čítač, který zpracovává impulsy o frekvenci 1 Hz (sekundové tiky). Jeho princip spočívá v tom, že čítač inkrementuje vteřiny do 59, následně přičte minutu a po dosažení 59 minut inkrementuje hodiny (v režimu 00–23). Modul umožňuje přímý zápis (nastavení) hodin a minut pomocí signálů `set_h` a `set_m`. Při nastavování se vteřiny automaticky vynulují, aby byl zajištěn přesný start měření.

![TIME_COUNTER](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/TIME_COUNTER.png)

**2. Stavový automat hodin ([`main_loop`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/main_loop.vhd))**

Tato část implementuje logiku přepínání mezi jednotlivými režimy zobrazení a nastavení. Je tvořen dvěmi nezávislými stavovými automaty, které běží paralelně.

![MAIN_LOOP](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/MAIN_LOOP.png)

1. _**Automat zobrazení**_ (`view_state`)**
   
Stavy systému: Automat přepíná mezi stavy pro zobrazení aktuálního času  `TIME_VIEW`  a dále mezi třemi různými budíky  `AL1_VIEW` až `AL3_VIEW`. Tento automat mění stavy pouze tehdy, když se nic nenastavuje, tedy když `set_state = S_OFF`. K přepínání se používají zechycené hrany tlačítek `mode_up_rise` a `mode_down_rise`.

**Tabulka přechodů a výstupů**

| Aktuální stav (`view_state`) | `mode_up_rise` | `mode_down_rise` | Následující stav | Kód stavu (`view_dbg`) | Výstup displeje (`view_sel`) |
| :--- | :---: | :---: | :--- | :---: | :---: |
| **TIME_VIEW** | `'1'` | `'0'` | **AL1_VIEW** | `"00"` | `"00"` |
| **TIME_VIEW** | `'0'` | `'1'` | **AL3_VIEW** | `"00"` | `"00"` |
| **AL1_VIEW**  | `'1'` | `'0'` | **AL2_VIEW** | `"01"` | `"01"` |
| **AL1_VIEW**  | `'0'` | `'1'` | **TIME_VIEW**  | `"01"` | `"01"` |
| **AL2_VIEW**  | `'1'` | `'0'` | **AL3_VIEW** | `"10"` | `"10"` |
| **AL2_VIEW**  | `'0'` | `'1'` | **AL1_VIEW** | `"10"` | `"10"` |
| **AL3_VIEW**  | `'1'` | `'0'` | **TIME_VIEW**  | `"11"` | `"11"` |
| **AL3_VIEW**  | `'0'` | `'1'` | **AL2_VIEW** | `"11"` | `"11"` |

**Poznámka:** Po resetu (`rst = '1'`) přejde automat vždy do výchozího stavu `TIME_VIEW`.

2. _**Automat nastavování**_ (`set_state`)**

Tento automat čeká na dlouhá podržení prostředního tlačítka po dobu **2s** a následně umožňuje přepínat mezi nystavováním hodin a minut. Jde o kombinaci Mooreona a Mealyho stavového automatu, protože signály `set_hh` a `set_mm` reagují na okamžitý stisk tlačítek, i když už ve stavu jsme.

**Tabulka přechodů nastavovacího automatu:**

| Aktuální stav (`set_state`) | Vstupní podmínka / Událost | Následující stav |
| :--- | :--- | :--- |
| **S_OFF** | `hold_cnt = LONG_PRESS` (tlačítko `set_btn` drženo 2s) | **S_HH** |
| **S_HH**  | Krátký stisk `mode_up_rise = '1'` | **S_MM** |
| **S_MM**  | Krátký stisk `mode_down_rise = '1'` | **S_HH** |
| **S_HH**  | Krátký stisk `set_btn_rise = '1'` (Potvrzení a odchod) | **S_OFF** |
| **S_MM**  | Krátký stisk `set_btn_rise = '1'` (Potvrzení a odchod) | **S_OFF** |

**Tabulka hardwarových výstupů a Mealyho logiky:**

*(Zkratka `U+D` znamená logický součet tlačítek: `up_btn OR down_btn`)*

| Stav (`set_state`) | Kód stavu (`set_dbg`) | Povolení úprav (`set_en`) | Vstup HH (`set_hh`) | Vstup MM (`set_mm`) | Blikání dvojtečky (`dot_on`) | Běh času (`run_time`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **S_OFF** | `"00"` | `'0'` | `'0'` | `'0'` | bliká 1 Hz (`ce_1s`) | `'1'` (Vždy běží) |
| **S_HH**  | `"01"` | `'1'` | `U+D` | `'0'` | `'1'` (Trvale svítí) | `'0'` (Při `TIME_VIEW`), jinak `'1'` |
| **S_MM**  | `"10"` | `'1'` | `'0'` | `U+D` | `'1'` (Trvale svítí) | `'0'` (Při `TIME_VIEW`), jinak `'1'` |

<div align="center">
  <img src="Images/Stavový diagram.drawio.png" width="750" alt="Stavový diagram">
  <p>
    <em><strong>Tab. 1:</strong> Blokové schéma stavového automatu pro řízení hodin </em>
  </p>
</div>

### Display
O zobrazování dat na 8místném sedmisegmentovém displeji desky Nexys A7 se stará modul [`display_driver`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/display_driver.vhd). Aby bylo dosaženo rozsvícení všech 8 cifer „najednou“, využívá se principu rychlého multiplexování. Cifry se střídají každé 2 milisekundy (obnovovací frekvence 500 Hz), což lidské oko díky setrvačnosti vnímá jako souvislý obraz. 

![DISPLAY-DRIVER](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/DISPLAY_DRIVER.png)

Displej je logicky rozdělen na tyto sekce:
* **Pravá část (AN0–AN3):** Slouží k zobrazení samotného času ve formátu `HH:MM`. Interní binární hodnoty jsou matematicky převáděny na desítky a jednotky, aby na displeji svítily správné číslice (0–9). Pokud je aktivní režim nastavování času, upravované číslice svítí staticky a pouze při stisku tlačítka (inkrementaci/dekrementaci) krátce probliknou, což uživateli dává okamžitou vizuální zpětnou vazbu o změně hodnoty.
* **Levá část (AN4–AN7):** Funguje jako stavový indikátor menu. Při sledování běžného času se zde zobrazuje text `Hod `. Jakmile uživatel přepne náhled na budíky, indikátor se změní na text `AL_1`, `AL_2` nebo `AL_3`.
* **Desetinná tečka (dvojtečka) (DP):** Při běžném chodu bliká s frekvencí 1 Hz (500 ms svítí, 500 ms nesvítí) a vizuálně tak odděluje hodiny a minuty. Jakmile uživatel vstoupí do režimu nastavování času, tečka přestane blikat a svítí trvale.

<br>
<div align="center">
  <table>
    <tr>
      <td align="center"><b>Běžný režim (Zobrazení času)</b></td>
      <td align="center"><b>Režim prohlížení (Náhled budíku)</b></td>
    </tr>
    <tr>
      <td><img src="Images/display_time.svg" width="400" alt="Běžný čas"></td>
      <td><img src="Images/display_mode_selection.svg" width="400" alt="Nastavení budíku"></td>
    </tr>
  </table>
</div>
<br>


Řízení displeje je zajištěno spoluprací několika hlavních procesů a sub-modulů:

1. **[`clk_en`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/clk_en.vhd) (Generátory časování):**
   Modul využívá dvě instance děličky frekvence ze základních 100 MHz. První generuje **2ms** povolovací pulz (`sig_en_2ms`) pro samotné multiplexování. Druhá generuje **500ms** pulz (`sig_en_500ms`) pro logiku blikání.

![CLOCK_ENABLE](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/CLOCK_ENABLE.png)

3. **Logika sestavení číslic a blikání (`p_digits` a `p_blink`):**
   Proces neustále připravuje hodnoty pro všech 8 pozic displeje (interní signály `d0` až `d7`) v závislosti na zvoleném `view_mode`. Zároveň sleduje stav nastavování – pokud uživatel mění například hodiny, proces maskuje data mezerou ("10000"), čímž vytváří efekt blikání.

4. **[`cnt_up_down`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/cnt_up_down.vhd) (Čítač / Ukazatel adresy):**
   Tříbitový synchronní čítač, který přijímá pulzy z `clk_en`. Neustále odpočítává v rozsahu od 7 do 0. Jeho aktuální hodnota slouží jako adresa, která říká nadřazenému multiplexoru, která z 8 cifer má být v danou chvíli fyzicky aktivní.

![CNT_UP_DOWN](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/CNT_UP_DOWN.png)

6. **[`bin2seg`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/bin2seg.vhd) (Převodník / Dekodér znaků):**
   Kombinační obvod, který funguje jako překladový slovník. Přijímá 5bitový datový signál a okamžitě ho převádí na 7bitový vektor pro jednotlivé segmenty (A-G) displeje. Obsahuje logiku pro číslice 0-9 a speciální znaky (A, L, _, H, o, d) potřebné pro navigaci v menu.

![BIN2SEG](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/BIN2SEG.png)

<div align="center">
  <img src="Images/bin2seg_tabulka_git.svg" width="450" alt="Pravdivostní tabulka bin2seg">
  <p>
    <em><strong>Tab. 1:</strong> Pravdivostní tabulka dekodéru pro číslice 0–9 a speciální znaky (A, L, _, H, o, d). Signály jsou aktivní v logické 0 (Common Anode).</em>
  </p>
</div>

#### Architektura a princip multiplexování
Samotný [`display_driver`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/display_driver.vhd) všechny tyto bloky propojuje a obsahuje centrální **multiplexor** (proces `p_mux`). Ten sleduje aktuální hodnotu z 3bitového čítače a na jejím základě provede tyto akce:
* Vybere správná předpřipravená 5bitová data (`d0`–`d7`) a pošle je do dekodéru `bin2seg`.
* Nastaví logickou "0" na příslušný pin sběrnice `AN` (Anody), čímž zapne napájení pouze pro konkrétní cifru na desce.
* Vyhodnotí, zda má na dané pozici svítit desetinná tečka (`dp_o`).

![DISPLAY_DRIVER](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/DISPLAY_DRIVER.png)

### Alarm
Systém budíku je plně hardwarový a nevyužívá žádný mikrokontrolér. Jeho řízení je rozděleno do tří nezávislých podmodulů, které se starají o uchování času, porovnání s reálnými hodinami a generování akustického signálu.

**1. Paměť budíku ([`alarm_memory.vhd`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/alarm_memory.vhd))**
Tento modul slouží jako nezávislé úložiště pro čas, na který je budík nastaven. 
* Čas se ukládá do vnitřních registrů a výchozí hodnota po resetu je `00:00`.
* Modul přijímá ošetřené signály z tlačítek (pulzy o délce jednoho taktu), pomocí kterých uživatel inkrementuje hodiny a minuty. Modul automaticky řeší přetečení (po 23. hodině následuje 0, po 59. minutě 0).

![ALARM_MEMORY](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/ALARM_MEMORY.png)

**2. Řídicí logika a FSM ([`alarm_control.vhd`](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/alarm_control.vhd))**
Jde o hlavní mozek celého alarmu. Obsahuje komparátor a stavový automat (FSM), který neustále porovnává reálný čas z hlavních hodin s časem uloženým v paměti budíku.
* **Aktivace:** Budík zvoní pouze pokud jsou splněny dvě podmínky: přepínač na desce je v poloze ON a aktuální čas se přesně shoduje s nastaveným časem budíku (ve vteřině 00).
* **Zastavení (Típnutí):** Jakmile budík začne zvonit, FSM se uzamkne ve stavu zvonění. K jeho zastavení musí uživatel stisknout levé tlačítko (`btnL`). FSM si toto stisknutí zapamatuje a alarm umlčí až do dalšího dne.

![ALARM_CONTROL](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/ALARM_CONTROL.png)

**3. Generátor signálu pro bzučák ([`buzzer_driver.vhd`])(https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/MAIN/buzzer_driver.vhd)**
Piezo bzučák připojený na Pmod konektor potřebuje pro generování zvuku PWM signál, protože se nejedná o aktivní bzučák s vlastní oscilační frekvencí.
* Modul generuje základní **tón o frekvenci cca 2 kHz** (lidskému uchu nepříjemný zvuk).
* Aby budík nepískal jednolitě, je tento tón hardwarově modulován pomalejším signálem o frekvenci **2 Hz**. Výsledkem je přerušovaný, rytmický efekt "pípání-pípání-pípání", typický pro klasické digitální budíky.

![BUZZER_DRIVER](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/VHDL/BUZZER_DRIVER.png)

## Instrukční návod

### Popis částí

Fyzické rozhraní Alarm_clock využívá  několik základních prvků:
* **8místný 7segmentový displej:** pravá polovina zobrazuje aktuální čas nebo upravovanou hodnotu, levá polovina slouží pro textovou indikaci aktuálního režimu (náhledy budíků).
* **5 tlačítek:** slouží k plynulé navigaci v menu, přepínání režimů a úpravě číselných hodnot.
* **Přepínače (sw0 – sw2, sw15):** slouží k fyzické aktivaci a deaktivaci jednotlivých budíků. Zvýšená poloha znamená, že je budík zapnutý. Vypínač `sw15` slouží jako tvrdý hardwarový reset celého systému.
* **LED diody (led0 – led2):** vizuálně potvrzují, že je konkrétní budík aktuálně aktivován.

### Popis ovládacích prvků

Po spuštění desky zařízení začne pracovat. Chod zařízení *řídí tlačítka na desce*. Umožňují **nastavovat čas**, **přepínat mezi jednotlivými módy** a přejít do **režimu nastavení času**.

![](https://github.com/VojtaKudela/DE1-Alarm-Clock/blob/main/Images/Popis%20ovl%C3%A1dac%C3%ADch%20prvk%C5%AF.png)

### Natavení času

Pro nastavení času (ať už hlavního, nebo budíku) je potřeba po dobu 2 sekund podržet prostřední tlačítko **NASTAVENÍ (btnC)**. Primárně je systém navržen tak, že se nejdříve nastavuje hodnota hodin (HH). K úpravě této hodnoty slouží tlačítka **TIME +/- (btnU / btnD)**. Čas hodin lze nastavovat v **rozmezí 0–23**. K přechodu z nastavování hodin na nastavování minut slouží pravé tlačítko **MODE MM (btnR)**. Minuty (MM) se nastavují naprosto stejným způsobem, a to v **rozmezí 0–59**. Při editaci se na displeji zobrazuje aktuálně měněná hodnota a blikající tečka svítí trvale, čímž uživatele upozorňuje na režim úprav. Pro finální potvrzení nastaveného času a návrat zpět stačí krátce stisknout prostřední tlačítko **NASTAVENÍ (btnC)**. 

### Nastavení módu

Základní mód zobrazení změníme stiskem levého tlačítka **MODE PŘEDCHOZÍ / DALŠÍ (btnL)**. Zařízení pracuje ve čtyřech módech: **HODINY, ALARM 1, ALARM 2** a **ALARM 3**. Aktuálně zvolený mód je vždy jasně indikován na levé straně displeje (např. `AL_1`). Dlouhým stiskem prostředního tlačítka z kteréhokoliv z těchto náhledů lze vstoupit do přímé úpravy daného času, jak je popsáno výše.

### Video ukázka
<div align="center">
  <a href="https://www.youtube.com/watch?v=QMtP-8n-iPY">
    <img src="https://img.youtube.com/vi/QMtP-8n-iPY/maxresdefault.jpg" alt="Video návod" width="600">
    <p><i>▶ Kliknutím spustíte video návod na YouTube </i></p>
  </a>
</div>

## Simulace a verifikace

V této sekci jsou zobrazeny průběhy simulací jednotlivých modulů, které ověřují správnost navržené logiky.

### 1. Paměť budíku (`alarm_memory`)
Simulace ověřuje ukládání času budíku a jeho inkrementaci pomocí pulsů `en_inc_hour` a `en_inc_min`.
<div><img src="Simulations/alarm_memory_sim.png" width="600" alt="Simulace paměti budíku"></div>

### 2. Dekodér na 7-segmentový displej (`bin2seg`)
Ověření převodu 5bitové binární hodnoty na kód pro 7segmentový displej (společná anoda), včetně speciálních znaků jako 'A', 'L' nebo '_'.
<div><img src="Simulations/bin2seg_sim.png" width="600" alt="Simulace dekodéru"></div>

### 3. Generátor pulzů (`clock_enable`)
Verifikace generování synchronizačních pulsů `ce` trvajících jeden hodinový takt v definovaných intervalech.
<div><img src="Simulations/clock_enable_sim.png" width="600" alt="Simulace clock enable"></div>

### 4. Ošetření zákmitů tlačítek (`debounce`)
Simulace demonstruje filtrování vstupního signálu z tlačítka a generování čistého pulsu `btn_press` na vzestupnou hranu stabilního stavu.
<div><img src="Simulations/debounce_sim.png" width="600" alt="Simulace debouncingu"></div>

### 5. Ovladač 8místného displeje (`driver_7seg_8digits`)
Strukturální simulace multiplexního řízení 8 pozic displeje pomocí anodových signálů `dig_o` a segmentů `seg_o`.
<div><img src="Simulations/driver_7_seg_8digits.png" width="600" alt="Simulace driveru displeje"></div>

### 6. Nastavení času (`time_setter`)
Ověření logiky pro manuální úpravu hodin a minut pomocí signálů `up_press`/`down_press` v závislosti na zvoleném módu `mode_sel`.
<div><img src="Simulations/time_setter_sim.png" width="600" alt="Simulace nastavení času"></div>

### 7. Hlavní čítač hodin a minut (`up_down_counter`)
Komplexní simulace obousměrného čítání času (HH:MM) s detekcí přetečení (23 -> 00, 59 -> 00) a ošetřením vstupních hran.
<div><img src="Simulations/up_down_counter_sim(1).png" width="600" alt="Simulace čítače 1"></div>
<div><img src="Simulations/up_down_counter_sim.png" width="600" alt="Simulace čítače 2"></div>

### 8. Řídicí logika alarmu (`alarm_control`)
Ověření komparační logiky pro spouštění budíku. Na průběhu je jasně vidět okamžik, kdy se aktuální čas (`curr_hh`, `curr_mm`, `curr_ss = 0`) shoduje s časem uloženým v paměti prvního budíku (`al1_h`, `al1_m`). Protože je tento budík uživatelem povolen (`en_al1 = '1'`), modul úspěšně vyvolá výstupní signál `ringing`.
<div><img src="Simulations/alarm_control_sim.png" width="600" alt="Simulace alarm_control"></div>

### 9. Hlavní čítač času (`time_counter`)
Simulace jádra hodin, která zachycuje dva hlavní režimy. Nejdříve je vidět běžný chod času (`run_time = '1'`), a následně přechod do režimu manuálního nastavování (`set_en = '1'`). V tomto režimu simulace ověřuje inkrementaci hodin (`HH`) a minut (`MM`) pomocí tlačítek `btn_up` a `btn_down`, přičemž je vidět správná synchronní nulování sekund (`SS`).
<div><img src="Simulations/time_counter_sim.png" width="600" alt="Simulace time_counter"></div>

### 10. Stavový automat řízení (`main_loop`)
Testování hlavní řídicí FSM logiky. Průběh demonstruje přepínání mezi režimy zobrazení (`view_sel`) pomocí navigačních tlačítek a následně ukazuje detekci dlouhého stisku potvrzovacího tlačítka (`set_btn`), čímž se systém přepne do editačního režimu (`set_en` přejde do logické 1) a postupně povoluje modifikaci hodin (`set_hh`) a minut (`set_mm`).
<div><img src="Simulations/main_loop_sim.png" width="600" alt="Simulace main_loop"></div>

### 11. Čítač pro multiplexování (`cnt_up_down`)
Ověření chování 3bitového čítače, který zajišťuje adresaci pro zobrazení na 8místném displeji. Simulace potvrzuje plynulé a nepřerušené čítání hodnot od 0 do 7 a následné přetečení zpět na nulu na základě povolovacího signálu `en`.
<div><img src="Simulations/cnt_up_down_sim.png" width="600" alt="Simulace cnt_up_down"></div>
<br>

## Návrh posteru
<img width="759" height="1011" alt="image" src="https://github.com/user-attachments/assets/0e9bd56b-ad60-486e-93c5-5b95d919f0b9" />


### PowerPoit dokument
[Alarm Clock.pptx](https://github.com/user-attachments/files/27324396/Alarm.Clock.pptx)

## REFERENCE
1. [Online VHDL Testbench Template Generator (lapinoo.net)](https://vhdl.lapinoo.net/testbench/).
2. [DATASHEET for Pasive Buzzer HW-508 V0.2](https://digizone.com.ve/wp-content/uploads/2022/03/KY-006-Joy-IT.pdf).
3. [Vytváření diagramů draw.io](https://www.drawio.com/).

### Pomoc s Githubem
4. [Jak upravovat README](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).
5. [Vytvoření složky](https://www.youtube.com/watch?v=FvCsnUgAdWA).
6. [Jak nahrát soubor](https://www.youtube.com/watch?v=ATVm6ACERu8).
