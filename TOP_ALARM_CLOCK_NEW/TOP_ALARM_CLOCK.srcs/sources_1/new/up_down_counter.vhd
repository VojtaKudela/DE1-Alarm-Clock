----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:32:58
-- Design Name: 
-- Module Name: up_down_counter - Behavioral
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

entity up_down_counter is
    Port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        
        up   : in  std_logic;  -- Impulz z tlačítka UP
        down : in  std_logic;  -- Impulz z tlačítka DOWN
        sel  : in  std_logic;  -- '0' = nastavujeme hodiny (HH), '1' = nastavujeme minuty (MM)
       
        HH   : out std_logic_vector(4 downto 0);
        MM   : out std_logic_vector(5 downto 0)
    );
end entity;

architecture Behavioral of up_down_counter is
    signal hours   : integer range 0 to 23 := 0;
    signal minutes : integer range 0 to 59 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hours   <= 0;
                minutes <= 0;
            else
                -- Inkrementace (tlačítko nahoru)
                if up = '1' then
                    if sel = '0' then
                        if hours = 23 then hours <= 0; else hours <= hours + 1; end if;
                    else
                        if minutes = 59 then minutes <= 0; else minutes <= minutes + 1; end if;
                    end if;
                    
                -- Dekrementace (tlačítko dolů)
                elsif down = '1' then
                    if sel = '0' then
                        if hours = 0 then hours <= 23; else hours <= hours - 1; end if;
                    else
                        if minutes = 0 then minutes <= 59; else minutes <= minutes - 1; end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Převod na standardní logický vektor pro výstup
    HH <= std_logic_vector(to_unsigned(hours, 5));
    MM <= std_logic_vector(to_unsigned(minutes, 6));
    
end Behavioral;
