----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:20:57
-- Design Name: 
-- Module Name: bin2seg - Behavioral
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

entity bin2seg is
    Port ( clear : in STD_LOGIC;
           bin   : in STD_LOGIC_VECTOR (4 downto 0);
           seg   : out STD_LOGIC_VECTOR (6 downto 0));
end bin2seg;

architecture Behavioral of bin2seg is
begin
    p_7seg_decoder : process (bin, clear) is
    begin
        if (clear = '1') then
            seg <= "1111111"; -- Displej zhasnutý (aktivní v nule)
        else
            case bin is
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
               when "01010" => seg <= "0001000"; -- A
               when "01011" => seg <= "1110001"; -- L      
               when "01100" => seg <= "1110111"; -- _ 
               when "01101" => seg <= "1001000"; -- H            
               when "01110" => seg <= "1100010"; -- o
               when "01111" => seg <= "1000010"; -- d
               when others  => seg <= "1111111"; -- empty
            end case;
        end if;    
    end process p_7seg_decoder;
    
end Behavioral;
