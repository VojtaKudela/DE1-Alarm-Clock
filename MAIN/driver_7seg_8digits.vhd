

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity driver_7seg_8digits is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        
        -- Vstupy pro pravou stranu (Cas)
        data0_i : in  std_logic_vector(4 downto 0);
        data1_i : in  std_logic_vector(4 downto 0);
        data2_i : in  std_logic_vector(4 downto 0);
        data3_i : in  std_logic_vector(4 downto 0);
        
        -- Vstupy pro levou stranu (Mod)
        data4_i : in  std_logic_vector(4 downto 0);
        data5_i : in  std_logic_vector(4 downto 0);
        data6_i : in  std_logic_vector(4 downto 0);
        data7_i : in  std_logic_vector(4 downto 0);
        
        -- Blikani tecky (napojeno na 1 Hz signal)
        dp_i    : in  std_logic;
        
        -- Vystupy na fyzicky displej
        dp_o    : out std_logic;
        seg_o   : out std_logic_vector(6 downto 0);
        dig_o   : out std_logic_vector(7 downto 0) -- Predloha pouziva dig_o pro anody
    );
end entity driver_7seg_8digits;

architecture Structural of driver_7seg_8digits is

    -- Vnitrni signaly pro propojeni komponent
    signal sig_en_2ms   : std_logic;
    signal sig_cnt_3bit : std_logic_vector(2 downto 0);
    signal sig_hex      : std_logic_vector(4 downto 0);

    -- 1. Deklarace clock_enable (z repozitare)
    component clock_enable is
        generic (
            g_MAX : natural
        );
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            ce    : out std_logic
        );
    end component;

    -- 2. Deklarace obousmerneho citace (z repozitare lab4/lab5)
    component cnt_up_down is
        generic (
            g_CNT_WIDTH : natural
        );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            en       : in  std_logic;
            cnt_up   : in  std_logic;
            cnt      : out std_logic_vector(g_CNT_WIDTH - 1 downto 0)
        );
    end component;

    -- 3. Deklarace tveho prevodniku
    component bin2seg is
        port (
            clear : in  std_logic;
            bin   : in  std_logic_vector(4 downto 0);
            seg   : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    ------------------------------------------------------------------------------
    -- Instance 1: clock_enable (generuje pulz kazde 2 ms pro Nexys A7)
    ------------------------------------------------------------------------------
    clk_en0 : component clock_enable
        generic map (
            g_MAX => 200000 -- 100 MHz / 200 000 = 500 Hz (2 ms perioda)
        )
        port map (
            clk   => clk,
            rst   => rst,
            ce    => sig_en_2ms
        );

    ------------------------------------------------------------------------------
    -- Instance 2: cnt_up_down (3bitovy citac 0 az 7)
    ------------------------------------------------------------------------------
    bin_cnt0 : component cnt_up_down
        generic map (
            g_CNT_WIDTH => 3
        )
        port map (
            clk      => clk,
            rst      => rst,
            en       => sig_en_2ms,
            cnt_up   => '0', -- Pocitame dolu (7, 6, 5...), aby to opticky sedelo zleva doprava
            cnt      => sig_cnt_3bit
        );

    ------------------------------------------------------------------------------
    -- Instance 3: bin2seg (Tvuj vlastni dekoder)
    ------------------------------------------------------------------------------
    bin2seg0 : component bin2seg
        port map (
            clear => rst,
            bin   => sig_hex,
            seg   => seg_o
        );

    ------------------------------------------------------------------------------
    -- Proces p_mux: Kombinacni multiplexor (presne podle predlohy)
    ------------------------------------------------------------------------------
    p_mux : process (sig_cnt_3bit, data0_i, data1_i, data2_i, data3_i, data4_i, data5_i, data6_i, data7_i, dp_i)
    begin
        case sig_cnt_3bit is
            when "111" =>
                sig_hex <= data7_i;
                dig_o   <= "01111111";
                dp_o    <= '1'; -- Tecka zhasnuta (aktivni v nule)

            when "110" =>
                sig_hex <= data6_i;
                dig_o   <= "10111111";
                dp_o    <= '1';

            when "101" =>
                sig_hex <= data5_i;
                dig_o   <= "11011111";
                dp_o    <= '1';

            when "100" =>
                sig_hex <= data4_i;
                dig_o   <= "11101111";
                dp_o    <= '1';

            when "011" =>
                sig_hex <= data3_i;
                dig_o   <= "11110111";
                dp_o    <= '1';

            when "010" =>
                sig_hex <= data2_i;
                dig_o   <= "11111011";
                -- Zde je tecka pro sekundy! Pokud dp_i = 1, dp_o bude 0 (sviti)
                dp_o    <= not dp_i;

            when "001" =>
                sig_hex <= data1_i;
                dig_o   <= "11111101";
                dp_o    <= '1';

            when others =>
                sig_hex <= data0_i;
                dig_o   <= "11111110";
                dp_o    <= '1';
        end case;
    end process p_mux;

end architecture Structural;