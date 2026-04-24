----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:18:56
-- Design Name: 
-- Module Name: cnt_up_down - Behavioral
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

entity cnt_up_down is
    generic (
        g_CNT_WIDTH : natural := 3
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        en       : in  std_logic;
        cnt_up   : in  std_logic;
        cnt      : out std_logic_vector(g_CNT_WIDTH - 1 downto 0)
    );
end entity cnt_up_down;

architecture behavioral of cnt_up_down is
    signal sig_cnt : unsigned(g_CNT_WIDTH - 1 downto 0);
begin
    p_cnt_up_down : process (clk) is
    begin
        if rising_edge(clk) then
            if (rst = '1') then               
                sig_cnt <= (others => '0');
            elsif (en = '1') then             
                if (cnt_up = '1') then
                    sig_cnt <= sig_cnt + 1;
                else
                    sig_cnt <= sig_cnt - 1;
                end if;
            end if;
        end if;
    end process p_cnt_up_down;

    cnt <= std_logic_vector(sig_cnt);

end Behavioral;