----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 22:32:02
-- Design Name: 
-- Module Name: time_setter_tb - Behavioral
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

-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Wed, 15 Apr 2026 20:31:48 GMT
-- Request id : cfwk-fed377c2-69dff5b492c80

entity tb_time_setter is
end tb_time_setter;



architecture tb of tb_time_setter is

    --------------------------------------------------------------------
    -- DUT component declaration
    --------------------------------------------------------------------
    component time_setter
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

    --------------------------------------------------------------------
    -- Signals
    --------------------------------------------------------------------
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal up_press   : std_logic := '0';
    signal down_press : std_logic := '0';
    signal mode_sel   : std_logic := '0';
    signal HH         : std_logic_vector (4 downto 0);
    signal MM         : std_logic_vector (5 downto 0);

    --------------------------------------------------------------------
    -- Clock constant
    --------------------------------------------------------------------
    constant TbPeriod : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- DUT instantiation
    --------------------------------------------------------------------
    dut : time_setter
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
    -- CLOCK GENERATOR (SAFE VERSION - NEVER STOPS)
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for TbPeriod / 2;
            clk <= '1';
            wait for TbPeriod / 2;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- STIMULI PROCESS
    --------------------------------------------------------------------
    stimuli : process
    begin
        ----------------------------------------------------------------
        -- INITIAL STATE
        ----------------------------------------------------------------
        up_press   <= '0';
        down_press <= '0';
        mode_sel   <= '0';
    
        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
    
        ----------------------------------------------------------------
        -- TEST 1: multiple HOURS increments
        ----------------------------------------------------------------
        mode_sel <= '0';
    
        wait for 20 ns;
    
        for i in 1 to 5 loop
            up_press <= '1';
            wait for 10 ns;
            up_press <= '0';
            wait for 40 ns;
        end loop;
    
        ----------------------------------------------------------------
        -- TEST 2: multiple MINUTES increments
        ----------------------------------------------------------------
        mode_sel <= '1';
    
        wait for 20 ns;
    
        for i in 1 to 3 loop
            up_press <= '1';
            wait for 10 ns;
            up_press <= '0';
            wait for 40 ns;
        end loop;
    
        ----------------------------------------------------------------
        -- TEST 3: multiple DECREMENTS
        ----------------------------------------------------------------
        for i in 1 to 2 loop
            down_press <= '1';
            wait for 10 ns;
            down_press <= '0';
            wait for 40 ns;
        end loop;
    
        ----------------------------------------------------------------
        -- TEST 4: rapid press burst (bounce-like scenario)
        ----------------------------------------------------------------
        mode_sel <= '0';
    
        wait for 50 ns;
    
        up_press <= '1';
        wait for 10 ns;
        up_press <= '0';
    
        wait for 10 ns;
    
        up_press <= '1';
        wait for 10 ns;
        up_press <= '0';
    
        wait for 10 ns;
    
        up_press <= '1';
        wait for 10 ns;
        up_press <= '0';
    
        ----------------------------------------------------------------
        -- RUN FURTHER
        ----------------------------------------------------------------
        wait for 1000 ns;
    
        ----------------------------------------------------------------
        -- END SIMULATION
        ----------------------------------------------------------------
        assert false
            report "End of simulation"
            severity failure;
    end process;

end tb;

configuration cfg_tb_time_setter of tb_time_setter is
    for tb
    end for;
end cfg_tb_time_setter;

