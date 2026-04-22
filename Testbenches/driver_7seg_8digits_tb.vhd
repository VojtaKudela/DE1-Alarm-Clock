----------------------------------------------------------------------------------
-- Module Name: cnt_up_down - Behavioral
-- Description: N-bit bidirectional counter with enable and synchronous reset.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_up_down is
    generic (
        g_CNT_WIDTH : natural := 3 -- Default number of bits
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
    -- Local counter
    signal sig_cnt : unsigned(g_CNT_WIDTH - 1 downto 0);
begin
    p_cnt_up_down : process (clk) is
    begin
        if rising_edge(clk) then
            if (rst = '1') then               -- Synchronous reset
                sig_cnt <= (others => '0');   -- Clear all bits
            elsif (en = '1') then             -- Test if clock enable is active
                if (cnt_up = '1') then
                    sig_cnt <= sig_cnt + 1;   -- Count up
                else
                    sig_cnt <= sig_cnt - 1;   -- Count down
                end if;
            end if;
        end if;
    end process p_cnt_up_down;

    -- Output must be retyped from unsigned to std_logic_vector
    cnt <= std_logic_vector(sig_cnt);
end architecture behavioral;