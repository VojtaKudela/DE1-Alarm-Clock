----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2026 21:43:52
-- Design Name: 
-- Module Name: time_counter_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_time_counter is
end tb_time_counter;

architecture tb of tb_time_counter is

    component time_counter
        port (clk       : in std_logic;
              rst       : in std_logic;
              ce_1s     : in std_logic;
              run_time  : in std_logic;
              set_en    : in std_logic;
              view_mode : in std_logic_vector (1 downto 0);
              set_hh    : in std_logic;
              set_mm    : in std_logic;
              btn_up    : in std_logic;
              btn_down  : in std_logic;
              HH        : out std_logic_vector (4 downto 0);
              MM        : out std_logic_vector (5 downto 0);
              SS        : out std_logic_vector (5 downto 0));
    end component;

    signal clk       : std_logic;
    signal rst       : std_logic;
    signal ce_1s     : std_logic;
    signal run_time  : std_logic;
    signal set_en    : std_logic;
    signal view_mode : std_logic_vector (1 downto 0);
    signal set_hh    : std_logic;
    signal set_mm    : std_logic;
    signal btn_up    : std_logic;
    signal btn_down  : std_logic;
    signal HH        : std_logic_vector (4 downto 0);
    signal MM        : std_logic_vector (5 downto 0);
    signal SS        : std_logic_vector (5 downto 0);

    -- Nastavena perioda 10 ns pro 100 MHz clock
    constant TbPeriod : time := 10 ns; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : time_counter
    port map (clk       => clk,
              rst       => rst,
              ce_1s     => ce_1s,
              run_time  => run_time,
              set_en    => set_en,
              view_mode => view_mode,
              set_hh    => set_hh,
              set_mm    => set_mm,
              btn_up    => btn_up,
              btn_down  => btn_down,
              HH        => HH,
              MM        => MM,
              SS        => SS);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- Pripojeni hodin
    clk <= TbClock;

    stimuli : process
    begin
        -- Inicializace vstupù
        ce_1s <= '0';
        run_time <= '0';
        set_en <= '0';
        view_mode <= "00";
        set_hh <= '0';
        set_mm <= '0';
        btn_up <= '0';
        btn_down <= '0';

        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- =================================================================
        -- TEST 1: Automatickı bìh èasu
        -- =================================================================
        report "TEST 1: Automaticky beh casu (SS by melo dojit do 3)";
        run_time <= '1';
        
        -- Vygenerujeme 3 pulzy po 1 sekundì (virtuálnì zrychleno)
        for i in 1 to 3 loop
            ce_1s <= '1'; 
            wait for TbPeriod; -- Pulz musí trvat alespoò jeden takt hodin
            ce_1s <= '0'; 
            wait for 10 * TbPeriod;
        end loop;
        
        run_time <= '0';
        wait for 50 ns;

        -- =================================================================
        -- TEST 2: Nastavování hodin a pøeteèení
        -- =================================================================
        report "TEST 2: Nastaveni hodin (test preteceni 0 -> 23 a zpet)";
        set_en <= '1';
        view_mode <= "00"; -- Musí bıt "00" pro hlavní èas
        set_hh <= '1';
        wait for 20 ns;

        -- Krok dolù: z 0 by mìly skoèit na 23
        btn_down <= '1'; wait for 2 * TbPeriod; btn_down <= '0'; wait for 5 * TbPeriod;
        
        -- Krok nahoru: z 23 by mìly skoèit na 0
        btn_up <= '1'; wait for 2 * TbPeriod; btn_up <= '0'; wait for 5 * TbPeriod;
        
        -- Krok nahoru: z 0 na 1
        btn_up <= '1'; wait for 2 * TbPeriod; btn_up <= '0'; wait for 5 * TbPeriod;
        
        set_hh <= '0';
        wait for 50 ns;

        -- =================================================================
        -- TEST 3: Nastavování minut a pøeteèení
        -- =================================================================
        report "TEST 3: Nastaveni minut (test preteceni 0 -> 59 a zpet)";
        set_mm <= '1';
        wait for 20 ns;

        -- Krok dolù: z 0 by mìly skoèit na 59
        btn_down <= '1'; wait for 2 * TbPeriod; btn_down <= '0'; wait for 5 * TbPeriod;
        
        -- Krok nahoru: z 59 by mìly skoèit na 0
        btn_up <= '1'; wait for 2 * TbPeriod; btn_up <= '0'; wait for 5 * TbPeriod;
        
        -- Krok nahoru: z 0 na 1
        btn_up <= '1'; wait for 2 * TbPeriod; btn_up <= '0'; wait for 5 * TbPeriod;

        -- =================================================================
        -- TEST 4: Vynulování sekund pøi nastavení
        -- =================================================================
        report "TEST 4: Vynulovani sekund po zasahu uzivatele";
        -- 1. Necháme sekundy trochu nabìhnout
        set_en <= '0'; 
        set_mm <= '0';
        run_time <= '1';
        
        ce_1s <= '1'; wait for TbPeriod; ce_1s <= '0'; wait for 10 * TbPeriod;
        ce_1s <= '1'; wait for TbPeriod; ce_1s <= '0'; wait for 10 * TbPeriod;
        -- V tuto chvili jsou sekundy > 0
        
        -- 2. Vstoupíme zpìt do nastavení a zmáèkneme tlaèítko
        run_time <= '0';
        set_en <= '1';
        set_mm <= '1';
        wait for 20 ns;
        
        -- Stisk tlaèítka (SS by se mìlo okamitì srazit na 0)
        btn_up <= '1'; wait for 2 * TbPeriod; btn_up <= '0'; wait for 5 * TbPeriod;

        -- Konec simulace
        wait for 100 ns;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_time_counter of tb_time_counter is
    for tb
    end for;
end cfg_tb_time_counter;
