----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 22:24:46
-- Design Name: 
-- Module Name: time_setter - Behavioral
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

entity time_setter is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        up_press   : in  std_logic;
        down_press : in  std_logic;
        mode_sel   : in  std_logic;  -- 0 = HH, 1 = MM
        HH         : out std_logic_vector(4 downto 0);
        MM         : out std_logic_vector(5 downto 0)
    );
end entity;

architecture Behavioral of time_setter is

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

                ----------------------------------------------------------------
                -- INCREMENT / DECREMENT (unified logic)
                ----------------------------------------------------------------
                if up_press = '1' then

                    if mode_sel = '0' then
                        -- HOURS up
                        if hours = 23 then
                            hours <= 0;
                        else
                            hours <= hours + 1;
                        end if;
                    else
                        -- MINUTES up
                        if minutes = 59 then
                            minutes <= 0;
                        else
                            minutes <= minutes + 1;
                        end if;
                    end if;

                elsif down_press = '1' then

                    if mode_sel = '0' then
                        -- HOURS down
                        if hours = 0 then
                            hours <= 23;
                        else
                            hours <= hours - 1;
                        end if;
                    else
                        -- MINUTES down
                        if minutes = 0 then
                            minutes <= 59;
                        else
                            minutes <= minutes - 1;
                        end if;
                    end if;

                end if;

            end if;
        end if;
    end process;

    HH <= std_logic_vector(to_unsigned(hours, 5));
    MM <= std_logic_vector(to_unsigned(minutes, 6));

end architecture;
