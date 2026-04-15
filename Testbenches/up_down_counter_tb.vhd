----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 20:51:54
-- Design Name: 
-- Module Name: up_down_counter_tb - Behavioral
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
        port (
            clk        : in std_logic;
            rst        : in std_logic;
            up_press   : in std_logic;
            down_press : in std_logic;
            mode_sel   : in std_logic;
            HH         : out std_logic_vector (4 downto 0);
            MM         : out std_logic_vector (5 downto 0)
        );
    end component;

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal up_press   : std_logic := '0';
    signal down_press : std_logic := '0';
    signal mode_sel   : std_logic := '0';

    signal HH         : std_logic_vector (4 downto 0);
    signal MM         : std_logic_vector (5 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbSimEnded : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    dut : time_counter
        port map (
            clk        => clk,
            rst        => rst,
            up_press   => up_press,
            down_press => down_press,
            mode_sel   => mode_sel,
            HH         => HH,
            MM         => MM
        );

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    clk <= not clk after TbPeriod/2 when TbSimEnded /= '1' else '0';

    --------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------
    stim_proc : process
    begin

        ------------------------------------------------------------
        -- INIT
        ------------------------------------------------------------
        up_press <= '0';
        down_press <= '0';
        mode_sel <= '0';

        rst <= '1';
        wait for 50 ns;
        rst <= '0';

        wait for 20 ns;

        ------------------------------------------------------------
        -- TEST 1: HOURS increment (mode_sel = 0)
        ------------------------------------------------------------
        report "TEST: HOURS increment";

        mode_sel <= '0';

        -- +1 hour
        up_press <= '1';
        wait for TbPeriod;
        up_press <= '0';

        wait for 20 ns;

        -- +1 hour
        up_press <= '1';
        wait for TbPeriod;
        up_press <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- TEST 2: MINUTES increment (mode_sel = 1)
        ------------------------------------------------------------
        report "TEST: MINUTES increment";

        mode_sel <= '1';

        -- +1 min
        up_press <= '1';
        wait for TbPeriod;
        up_press <= '0';

        wait for 20 ns;

        -- +1 min
        up_press <= '1';
        wait for TbPeriod;
        up_press <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- TEST 3: decrement minutes
        ------------------------------------------------------------
        report "TEST: MINUTES decrement";

        down_press <= '1';
        wait for TbPeriod;
        down_press <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- FINISH
        ------------------------------------------------------------
        report "Simulation finished";

        TbSimEnded <= '1';
        wait;

    end process;

end tb;

configuration cfg_tb_time_counter of tb_time_counter is
    for tb
    end for;
end cfg_tb_time_counter;
