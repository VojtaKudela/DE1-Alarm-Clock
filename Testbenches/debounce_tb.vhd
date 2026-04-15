----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 18:35:50
-- Design Name: 
-- Module Name: debounce_tb - Behavioral
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

entity tb_debounce is
end tb_debounce;

architecture tb of tb_debounce is

    component debounce
        generic (
            C_SHIFT_LEN : positive := 4;
            C_MAX       : positive := 5
        );
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            btn_in    : in std_logic;
            btn_state : out std_logic;
            btn_press : out std_logic
        );
    end component;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal btn_in    : std_logic := '0';
    signal btn_state : std_logic;
    signal btn_press : std_logic;

    constant TbPeriod : time := 10 ns;

begin

    ------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------
    dut : debounce
        generic map (
            C_SHIFT_LEN => 4,
            C_MAX       => 5
        )
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btn_in,
            btn_state => btn_state,
            btn_press => btn_press
        );

    ------------------------------------------------------------
    -- CLOCK
    ------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for TbPeriod/2;
            clk <= '1';
            wait for TbPeriod/2;
        end loop;
    end process;

    ------------------------------------------------------------
    -- STIMULI
    ------------------------------------------------------------
    stimuli : process
    begin

        --------------------------------------------------------
        -- RESET
        --------------------------------------------------------
        btn_in <= '0';
        rst <= '1';
        wait for 50 ns;
        rst <= '0';

        wait for 100 ns;

        --------------------------------------------------------
        -- TEST 1: press with bounce
        --------------------------------------------------------
        btn_in <= '1';
        wait for 20 ns;

        btn_in <= '0';
        wait for 10 ns;

        btn_in <= '1';
        wait for 15 ns;

        btn_in <= '1';  -- stable
        wait for 150 ns;

        --------------------------------------------------------
        -- TEST 2: release with bounce
        --------------------------------------------------------
        btn_in <= '0';
        wait for 20 ns;

        btn_in <= '1';
        wait for 10 ns;

        btn_in <= '0';  -- stable
        wait for 150 ns;

        --------------------------------------------------------
        -- TEST 3: second press
        --------------------------------------------------------
        btn_in <= '1';
        wait for 10 ns;
        btn_in <= '0';
        wait for 10 ns;
        btn_in <= '1';
        wait for 120 ns;

        --------------------------------------------------------
        -- TEST 4: long hold
        --------------------------------------------------------
        btn_in <= '1';
        wait for 300 ns;
        btn_in <= '0';
        wait for 100 ns;

        --------------------------------------------------------
        -- END
        --------------------------------------------------------
        wait for 200 ns;

        assert false
            report "End of simulation"
            severity failure;

    end process;

end tb;

------------------------------------------------------------
-- configuration
------------------------------------------------------------
configuration cfg_tb_debounce of tb_debounce is
    for tb
    end for;
end cfg_tb_debounce;
