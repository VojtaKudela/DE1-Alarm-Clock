----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Lukáš Katrňák
-- Copyright (c) 2026 Lukáš Katrňák, MIT license
-- 
-- Create Date: 23.04.2026 15:18:56
-- Design Name: cnt_up_down
-- Module Name: cnt_up_down - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module implements a parametrizable up/down binary counter.
-- The counter increments or decrements its value on each rising
-- edge of the clock when enabled. The counting direction is
-- controlled by the cnt_up input.
--
-- The counter width is configurable using a generic parameter,
-- making this module reusable for various counting purposes
-- (e.g., display multiplexing, state indexing, timing logic)

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


entity cnt_up_down is
    generic (
        g_CNT_WIDTH : natural := 3       -- Width of the counter in bits
    );
    port (
        clk    : in  std_logic;          -- Main system clock
        rst    : in  std_logic;          -- High-active synchronous reset
        en     : in  std_logic;          -- Counter enable
        cnt_up : in  std_logic;          -- Count direction control
                                          -- '1' = increment, '0' = decrement
        cnt    : out std_logic_vector(
                     g_CNT_WIDTH - 1 downto 0
                 )                       -- Current counter value
    );
end entity cnt_up_down;

-------------------------------------------------
-- Up/Down Counter Architecture
-------------------------------------------------
architecture Behavioral of cnt_up_down is

    -- Internal counter stored as unsigned for
    -- proper arithmetic operations (add/sub)
    signal sig_cnt : unsigned(
                        g_CNT_WIDTH - 1 downto 0
                     );

begin

    -------------------------------------------------
    -- Counter Process
    -- Updates the counter value on rising edge
    -------------------------------------------------
    p_cnt_up_down : process (clk) is
    begin
        if rising_edge(clk) then

            -- Synchronous reset:
            -- counter is cleared to zero
            if (rst = '1') then               
                sig_cnt <= (others => '0');

            -- Counter updates only when enabled
            elsif (en = '1') then             

                -- Count direction selection
                if (cnt_up = '1') then
                    -- Increment counter
                    sig_cnt <= sig_cnt + 1;
                else
                    -- Decrement counter
                    sig_cnt <= sig_cnt - 1;
                end if;

            end if;
        end if;
    end process p_cnt_up_down;

    -------------------------------------------------
    -- Output Mapping
    -- Converts internal unsigned counter to
    -- std_logic_vector for external use
    -------------------------------------------------
    cnt <= std_logic_vector(sig_cnt);

end Behavioral;
