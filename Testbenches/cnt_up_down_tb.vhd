----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.04.2026 17:35:46
-- Design Name: 
-- Module Name: cnt_up_down_tb - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cnt_up_down is
end tb_cnt_up_down;

architecture tb of tb_cnt_up_down is

    constant C_WIDTH : natural := 3;

    component cnt_up_down
        generic (
            g_CNT_WIDTH : natural
        );
        port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            en     : in  std_logic;
            cnt_up : in  std_logic;
            cnt    : out std_logic_vector(g_CNT_WIDTH - 1 downto 0)
        );
    end component;

    signal clk    : std_logic;
    signal rst    : std_logic;
    signal en     : std_logic;
    signal cnt_up : std_logic;
    signal cnt    : std_logic_vector(C_WIDTH - 1 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : cnt_up_down
        generic map (
            g_CNT_WIDTH => C_WIDTH
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => en,
            cnt_up => cnt_up,
            cnt    => cnt
        );

    TbClock <= not TbClock after TbPeriod / 2 when TbSimEnded /= '1' else '0';
    clk     <= TbClock;

    stimuli : process
    begin
        en     <= '0';
        cnt_up <= '1';

        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        en <= '1';
        
        wait for 80 * TbPeriod;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_cnt_up_down of tb_cnt_up_down is
    for tb
    end for;
end cfg_tb_cnt_up_down;