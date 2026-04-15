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

entity time_counter is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;

        up     : in  std_logic;
        down   : in  std_logic;

        sel    : in  std_logic;  -- 0 = hours, 1 = minutes

        HH     : out std_logic_vector(4 downto 0);
        MM     : out std_logic_vector(5 downto 0)
    );
end entity;

architecture Behavioral of time_counter is

    -- internal registers
    signal hours   : integer range 0 to 23 := 0;
    signal minutes : integer range 0 to 59 := 0;

    -- edge lock (prevents multiple increments)
    signal up_d, down_d : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                hours   <= 0;
                minutes <= 0;
                up_d    <= '0';
                down_d  <= '0';

            else

                ----------------------------------------------------------------
                -- detect rising edge of UP pulse
                ----------------------------------------------------------------
                if (up = '1' and up_d = '0') then

                    if sel = '0' then
                        -- HOURS
                        if hours = 23 then
                            hours <= 0;
                        else
                            hours <= hours + 1;
                        end if;

                    else
                        -- MINUTES
                        if minutes = 59 then
                            minutes <= 0;
                        else
                            minutes <= minutes + 1;
                        end if;
                    end if;

                ----------------------------------------------------------------
                -- detect rising edge of DOWN pulse
                ----------------------------------------------------------------
                elsif (down = '1' and down_d = '0') then

                    if sel = '0' then
                        -- HOURS
                        if hours = 0 then
                            hours <= 23;
                        else
                            hours <= hours - 1;
                        end if;

                    else
                        -- MINUTES
                        if minutes = 0 then
                            minutes <= 59;
                        else
                            minutes <= minutes - 1;
                        end if;
                    end if;

                end if;

                -- store previous states
                up_d   <= up;
                down_d <= down;

            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- outputs
    --------------------------------------------------------------------
    HH <= std_logic_vector(to_unsigned(hours, 5));
    MM <= std_logic_vector(to_unsigned(minutes, 6));

end architecture;