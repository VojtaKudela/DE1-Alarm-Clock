----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Lukáš Katrňák
-- Copyright (c) 2026 Lukáš Katrňák, MIT license 
-- 
-- Create Date: 23.04.2026 15:20:57
-- Design Name: bin2seg
-- Module Name: bin2seg - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module implements a binary-to-7-segment decoder.
-- It converts a 5-bit binary input value into a segment
-- pattern suitable for a 7-segment display.
--
-- The module supports numeric characters (0-9) as well as
-- several alphabetic and symbolic characters used in the
-- alarm clock display (e.g. A, L, r).
--
-- The display is assumed to be active-low

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

entity bin2seg is
    port (
        clear : in  std_logic;                    -- Display clear (active high)
        bin   : in  std_logic_vector(4 downto 0); -- Binary symbol selector
        seg   : out std_logic_vector(6 downto 0)  -- Segment outputs (a-g)
    );
end bin2seg;

-------------------------------------------------
-- Binary to 7-Segment Decoder Architecture
-------------------------------------------------
architecture Behavioral of bin2seg is
begin

    -------------------------------------------------
    -- 7-Segment Decoder Process
    -- Combinational logic mapping binary codes
    -- to segment activation patterns.
    -------------------------------------------------
    p_7seg_decoder : process (bin, clear) is
    begin
        -- Clear condition:
        -- All segments off (display blank)
        -- Note: active-low display (1 = off)
        if (clear = '1') then
            seg <= "1111111";

        else
            -- Decode selected symbol
            case bin is

                -- Decimal digits
                when "00000" => seg <= "0000001"; -- 0
                when "00001" => seg <= "1001111"; -- 1
                when "00010" => seg <= "0010010"; -- 2
                when "00011" => seg <= "0000110"; -- 3
                when "00100" => seg <= "1001100"; -- 4
                when "00101" => seg <= "0100100"; -- 5
                when "00110" => seg <= "0100000"; -- 6
                when "00111" => seg <= "0001111"; -- 7
                when "01000" => seg <= "0000000"; -- 8
                when "01001" => seg <= "0000100"; -- 9

                -- Alphabetic / symbolic characters
                when "01010" => seg <= "0001000"; -- A
                when "01011" => seg <= "1110001"; -- L
                when "01100" => seg <= "1110111"; -- r (lowercase style)
                when "01101" => seg <= "1001000"; -- H
                when "01110" => seg <= "1100010"; -- o
                when "01111" => seg <= "1000010"; -- d

                -- Undefined values ? blank display
                when others  => seg <= "1111111";

            end case;
        end if;
    end process p_7seg_decoder;

end Behavioral;
