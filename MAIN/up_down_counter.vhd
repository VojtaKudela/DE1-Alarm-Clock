----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 20:49:16
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
        clk          : in  std_logic;
        rst          : in  std_logic;

        up_hours     : in  std_logic;
        down_hours   : in  std_logic;

        up_minutes   : in  std_logic;
        down_minutes : in  std_logic;

        HH           : out std_logic_vector(4 downto 0);
        MM           : out std_logic_vector(5 downto 0)
    );
end up_down_counter;

architecture Behavioral of up_down_counter is

    signal hours   : integer range 0 to 23 := 0;
    signal minutes : integer range 0 to 59 := 0;

    signal up_hours_d     : std_logic := '0';
    signal down_hours_d   : std_logic := '0';
    signal up_minutes_d   : std_logic := '0';
    signal down_minutes_d : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then

            ----------------------------------------------------------------
            -- RESET
            ----------------------------------------------------------------
            if rst = '1' then
                hours   <= 0;
                minutes <= 0;

                up_hours_d     <= '0';
                down_hours_d   <= '0';
                up_minutes_d   <= '0';
                down_minutes_d <= '0';

            else

                ----------------------------------------------------------------
                -- EDGE DETECTION (HOURS PRIORITY LOGIC)
                ----------------------------------------------------------------
                if (up_hours = '1' and up_hours_d = '0') then
                    if hours = 23 then
                        hours <= 0;
                    else
                        hours <= hours + 1;
                    end if;

                elsif (down_hours = '1' and down_hours_d = '0') then
                    if hours = 0 then
                        hours <= 23;
                    else
                        hours <= hours - 1;
                    end if;
                end if;

                ----------------------------------------------------------------
                -- EDGE DETECTION (MINUTES)
                ----------------------------------------------------------------
                if (up_minutes = '1' and up_minutes_d = '0') then
                    if minutes = 59 then
                        minutes <= 0;
                    else
                        minutes <= minutes + 1;
                    end if;

                elsif (down_minutes = '1' and down_minutes_d = '0') then
                    if minutes = 0 then
                        minutes <= 59;
                    else
                        minutes <= minutes - 1;
                    end if;
                end if;

                ----------------------------------------------------------------
                -- UPDATE EDGE REGISTERS (VŽDY NA KONCI)
                ----------------------------------------------------------------
                up_hours_d     <= up_hours;
                down_hours_d   <= down_hours;
                up_minutes_d   <= up_minutes;
                down_minutes_d <= down_minutes;

            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- OUTPUTS
    --------------------------------------------------------------------
    HH <= std_logic_vector(to_unsigned(hours, 5));
    MM <= std_logic_vector(to_unsigned(minutes, 6));

end Behavioral;
