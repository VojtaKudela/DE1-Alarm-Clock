----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:35:05
-- Design Name: 
-- Module Name: time_control - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_control is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        but_up   : in  std_logic;
        but_down : in  std_logic;
        set_hh   : in  std_logic;
        set_mm   : in  std_logic;
        
        HH       : out std_logic_vector(4 downto 0);
        MM       : out std_logic_vector(5 downto 0)
    );
end entity;

architecture Behavioral of time_control is
    signal up_pulse, down_pulse : std_logic;
begin
    -- Ošetření tlačítek pro inkrementaci/dekrementaci
    DEB_UP : entity work.debounce
        port map (clk => clk, rst => rst, btn_in => but_up, btn_press => up_pulse);

    DEB_DOWN : entity work.debounce
        port map (clk => clk, rst => rst, btn_in => but_down, btn_press => down_pulse);

    -- Hlavní čítač času (při nastavování)
    -- sel = '0' pro hodiny, '1' pro minuty
    COUNTER_EDIT : entity work.up_down_counter
        port map (
            clk    => clk,
            rst    => rst,
            up     => up_pulse,
            down   => down_pulse,
            sel    => set_mm, 
            HH     => HH,
            MM     => MM
        );
end Behavioral;
