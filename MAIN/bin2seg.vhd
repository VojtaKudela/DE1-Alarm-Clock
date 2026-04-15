----------------------------------------------------------------------------------
-- Module Name: bin2seg - Behavioral
-- Description: 7-segment decoder with numbers 0-9 and custom characters
--              (A, L, _, H, o, d). Active low (0 = ON).
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bin2seg is
    Port ( clear : in STD_LOGIC;
           bin : in STD_LOGIC_VECTOR (4 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end bin2seg;

architecture Behavioral of bin2seg is

begin
-- This combinational process decodes binary
-- input (`bin`) into 7-segment display output
-- (`seg`) for a Common Anode configuration.
p_7seg_decoder : process (bin, clear) is
begin

  if (clear = '1') then
    seg <= "1111111";  -- Clear the display
  else

    case bin is
       -- Numbers 0 - 9
       when "00000" => 
        seg <= "0000001";  -- 0
       when "00001" =>
        seg <= "1001111";  -- 1
       when "00010" =>
        seg <= "0010010";  -- 2
       when "00011" =>
        seg <= "0000110";  -- 3
       when "00100" =>
        seg <= "1001100";  -- 4
       when "00101" =>
        seg <= "0100100";  -- 5
       when "00110" =>
        seg <= "0100000";  -- 6
       when "00111" =>
        seg <= "0001111";  -- 7
       when "01000" =>
        seg <= "0000000";  -- 8
       when "01001" =>
        seg <= "0000100";  -- 9

       -- Custom characters
       when "01010" =>
        seg <= "0001000";  -- A
       when "01011" =>
        seg <= "1110001";  -- L      
       when "01100" =>
        seg <= "1110111";  -- _ 
       when "01101" =>
        seg <= "1001000";  -- H            
       when "01110" =>
        seg <= "1100010";  -- o
       when "01111" =>
        seg <= "1000010";  -- d

       -- All other states clear the display
       when others =>
        seg <= "1111111";  -- empty
      
    end case;

  end if;    
end process p_7seg_decoder;

end Behavioral;