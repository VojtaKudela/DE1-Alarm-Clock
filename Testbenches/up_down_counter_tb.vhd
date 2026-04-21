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

entity tb_up_down_counter is
end tb_up_down_counter;

architecture tb of tb_up_down_counter is

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    component up_down_counter
        port (
            clk        : in std_logic;
            rst        : in std_logic;

            up_hours   : in std_logic;
            down_hours : in std_logic;

            up_minutes   : in std_logic;
            down_minutes : in std_logic;

            HH : out std_logic_vector(4 downto 0);
            MM : out std_logic_vector(5 downto 0)
        );
    end component;

    --------------------------------------------------------------------
    -- signals
    --------------------------------------------------------------------
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal up_hours     : std_logic := '0';
    signal down_hours   : std_logic := '0';
    signal up_minutes   : std_logic := '0';
    signal down_minutes : std_logic := '0';

    signal HH : std_logic_vector(4 downto 0);
    signal MM : std_logic_vector(5 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    dut : up_down_counter
        port map (
            clk => clk,
            rst => rst,

            up_hours   => up_hours,
            down_hours => down_hours,

            up_minutes   => up_minutes,
            down_minutes => down_minutes,

            HH => HH,
            MM => MM
        );

    --------------------------------------------------------------------
    -- CLOCK
    --------------------------------------------------------------------
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    --------------------------------------------------------------------
    -- STIMULI
    --------------------------------------------------------------------
    stimuli : process
    begin

        ------------------------------------------------------------
        -- INIT + RESET
        ------------------------------------------------------------
        up_hours <= '0';
        down_hours <= '0';
        up_minutes <= '0';
        down_minutes <= '0';

        rst <= '1';
        wait for 10 ns;
        rst <= '0';

        wait for 20 ns;

        ------------------------------------------------------------
        -- 1) KRÁTKÝ STISK HOURS +
        ------------------------------------------------------------
        up_hours <= '1';
        wait for TbPeriod;        -- 1 clock pulse
        up_hours <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- 2) DLOUHÝ STISK HOURS -
        ------------------------------------------------------------
        down_hours <= '1';
        wait for 120 ns;          -- držení
        down_hours <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- 3) KRÁTKÝ STISK MINUTES +
        ------------------------------------------------------------
        up_minutes <= '1';
        wait for TbPeriod;
        up_minutes <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- 4) DLOUHÝ STISK MINUTES -
        ------------------------------------------------------------
        down_minutes <= '1';
        wait for 150 ns;
        down_minutes <= '0';

        wait for 50 ns;

        ------------------------------------------------------------
        -- 5) RYCHLÉ OPAKOVANÉ KLIKÁNÍ (bounce-like test)
        ------------------------------------------------------------
        up_hours <= '1';
        wait for TbPeriod;
        up_hours <= '0';
        wait for TbPeriod;

        up_hours <= '1';
        wait for TbPeriod;
        up_hours <= '0';

        wait for 100 ns;
        
        ------------------------------------------------------------
        -- 6) RYCHLÉ OPAKOVANÉ KLIKÁNÍ MINUTES (bounce-like test)
        ------------------------------------------------------------
        up_minutes <= '1';
        wait for TbPeriod;
        up_minutes <= '0';
        wait for TbPeriod;

        up_minutes <= '1';
        wait for TbPeriod;
        up_minutes <= '0';

        wait for 120 ns;
        
        up_minutes <= '1';
        wait for TbPeriod;
        up_minutes <= '0';
        
        wait for 20 ns;
        
        up_minutes <= '1';
        wait for TbPeriod;
        up_minutes <= '0';
        
        wait for 50 ns;
        
        down_minutes <= '1';
        wait for TbPeriod;
        down_minutes <= '0';

        wait for 100 ns;
        
        ------------------------------------------------------------
        -- 5) RYCHLÉ OPAKOVANÉ KLIKÁNÍ S PŘETEČENÍM HODIN
        ------------------------------------------------------------
        down_hours <= '1';
        wait for TbPeriod;
        down_hours <= '0';
        wait for TbPeriod;
        
        down_hours <= '1';
        wait for TbPeriod;
        down_hours <= '0';
        wait for TbPeriod;
        
        down_hours <= '1';
        wait for TbPeriod;
        down_hours <= '0';
        wait for TbPeriod;
        
        down_hours <= '1';
        wait for TbPeriod;
        down_hours <= '0';

        wait for 100 ns;
        
        ------------------------------------------------------------
        -- END
        ------------------------------------------------------------
        wait for 200 ns;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_up_down_counter of tb_up_down_counter is
    for tb
    end for;
end cfg_tb_up_down_counter;
