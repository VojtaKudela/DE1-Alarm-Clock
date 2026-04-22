----------------------------------------------------------------------------------
-- Module Name: clock_enable - Behavioral
-- Description: Generates clock enable signal according to the defined generic
--              value g_MAX.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_enable is
    generic (
        g_MAX : natural := 5 -- Number of clk pulses to generate one enable signal period
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        ce  : out std_logic
    );
end entity clock_enable;

architecture behavioral of clock_enable is
    -- Local counter
    signal sig_cnt : natural;
begin
    p_clk_enable : process (clk) is
    begin
        if rising_edge(clk) then
            if (rst = '1') then             -- Synchronous reset
                sig_cnt <= 0;               -- Clear local counter
                ce      <= '0';             -- Set output to low
            elsif (sig_cnt >= (g_MAX - 1)) then
                sig_cnt <= 0;               -- Clear local counter
                ce      <= '1';             -- Generate clock enable pulse
            else
                sig_cnt <= sig_cnt + 1;
                ce      <= '0';
            end if;
        end if;
    end process p_clk_enable;
end architecture behavioral;