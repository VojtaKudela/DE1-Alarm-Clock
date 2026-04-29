----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtěch Kudela
-- @copyright (c) 2026 Vojtěch Kudela, MIT license
-- 
-- Create Date: 23.04.2026 14:51:22
-- Design Name: ¨clock_enable
-- Module Name: clock_enable - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module implements a periodic pulse generator used as 
-- a clock enable signal. It allows slowing down processes 
-- (like counters or FSMs) while staying in the main high-speed 
-- clock domain.
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

entity clk_en is
    generic (
        G_MAX : positive := 100_000_000 -- Number of clk periods to generate one CE pulse
    );
    port (
        clk : in  std_logic; -- Main system clock
        rst : in  std_logic; -- High-active synchronous reset
        ce  : out std_logic  -- Clock enable pulse (active high for one clk cycle)
    );
end entity clk_en;

-------------------------------------------------
-- Clock Enable Architecture
architecture Behavioral of clk_en is

    -- Internal counter signal
    signal count : integer range 0 to G_MAX - 1;

begin

    -------------------------------------------------
    -- Clock Enable Generation Process
    -- Increments the counter on each rising edge of clk.
    -- When G_MAX is reached, 'ce' is asserted and counter resets.
    -------------------------------------------------
    p_clk_enable : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Synchronous reset of the counter and output
                count <= 0;
                ce    <= '0';

            elsif count = G_MAX - 1 then
                -- Pulse generation and counter wrap-around
                count <= 0;
                ce    <= '1';

            else
                -- Normal counting operation
                count <= count + 1;
                ce    <= '0';
                
            end if;
        end if;
    end process p_clk_enable;

end Behavioral;
