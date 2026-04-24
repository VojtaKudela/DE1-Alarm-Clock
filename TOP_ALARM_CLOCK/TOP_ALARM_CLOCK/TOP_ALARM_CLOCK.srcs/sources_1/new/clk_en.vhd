----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 14:51:22
-- Design Name: 
-- Module Name: clock_enable - Behavioral
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

entity clk_en is
    generic (G_MAX : positive := 100_000_000 -- Pro 100MHz hodiny a 1Hz
             );
    port (clk : in  std_logic;
          rst : in  std_logic;
          ce  : out std_logic
          );
          
end entity clk_en;

architecture Behavioral of clk_en is
    signal sig_cnt : integer range 0 to G_MAX - 1;
begin
    p_clk_enable : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ce      <= '0';
                sig_cnt <= 0;
            elsif sig_cnt = G_MAX - 1 then
                ce      <= '1';
                sig_cnt <= 0;
            else
                ce      <= '0';
                sig_cnt <= sig_cnt + 1;
            end if;
        end if;
    end process p_clk_enable;
end Behavioral;
