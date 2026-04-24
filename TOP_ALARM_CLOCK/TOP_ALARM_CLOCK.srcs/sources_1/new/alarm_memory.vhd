----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:11:36
-- Design Name: 
-- Module Name: alarm_memory - Behavioral
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
use ieee.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alarm_memory is
    port (
        clk, rst : in std_logic;
        btn_up, btn_down : in std_logic;
        view_mode : in std_logic_vector(1 downto 0);
        set_en, set_hh, set_mm : in std_logic;
        disp_hh : out unsigned(4 downto 0);
        disp_mm : out unsigned(5 downto 0);
        al1_h, al2_h, al3_h : out unsigned(4 downto 0);
        al1_m, al2_m, al3_m : out unsigned(5 downto 0)
    );
end entity;

architecture behavioral of alarm_memory is
    signal a1_h : integer range 0 to 23 := 6; 
    signal a1_m : integer range 0 to 59 := 0;
    signal a2_h : integer range 0 to 23 := 7; 
    signal a2_m : integer range 0 to 59 := 0;
    signal a3_h : integer range 0 to 23 := 8; 
    signal a3_m : integer range 0 to 59 := 0;
    signal btn_up_d   : std_logic := '0';
    signal btn_down_d : std_logic := '0';
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                a1_h <= 6; a1_m <= 0; a2_h <= 7; a2_m <= 0; a3_h <= 8; a3_m <= 0;
                btn_up_d <= '0'; btn_down_d <= '0';
            else
                btn_up_d <= btn_up; btn_down_d <= btn_down;

                if set_en = '1' then
                    if set_hh = '1' then
                        if btn_up = '1' and btn_up_d = '0' then
                            if view_mode = "01" then if a1_h = 23 then a1_h <= 0; else a1_h <= a1_h + 1; end if;
                            elsif view_mode = "10" then if a2_h = 23 then a2_h <= 0; else a2_h <= a2_h + 1; end if;
                            elsif view_mode = "11" then if a3_h = 23 then a3_h <= 0; else a3_h <= a3_h + 1; end if;
                            end if;
                        elsif btn_down = '1' and btn_down_d = '0' then
                            if view_mode = "01" then if a1_h = 0 then a1_h <= 23; else a1_h <= a1_h - 1; end if;
                            elsif view_mode = "10" then if a2_h = 0 then a2_h <= 23; else a2_h <= a2_h - 1; end if;
                            elsif view_mode = "11" then if a3_h = 0 then a3_h <= 23; else a3_h <= a3_h - 1; end if;
                            end if;
                        end if;
                    elsif set_mm = '1' then
                        if btn_up = '1' and btn_up_d = '0' then
                            if view_mode = "01" then if a1_m = 59 then a1_m <= 0; else a1_m <= a1_m + 1; end if;
                            elsif view_mode = "10" then if a2_m = 59 then a2_m <= 0; else a2_m <= a2_m + 1; end if;
                            elsif view_mode = "11" then if a3_m = 59 then a3_m <= 0; else a3_m <= a3_m + 1; end if;
                            end if;
                        elsif btn_down = '1' and btn_down_d = '0' then
                            if view_mode = "01" then if a1_m = 0 then a1_m <= 59; else a1_m <= a1_m - 1; end if;
                            elsif view_mode = "10" then if a2_m = 0 then a2_m <= 59; else a2_m <= a2_m - 1; end if;
                            elsif view_mode = "11" then if a3_m = 0 then a3_m <= 59; else a3_m <= a3_m - 1; end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    disp_hh <= to_unsigned(a1_h, 5) when view_mode = "01" else to_unsigned(a2_h, 5) when view_mode = "10" else to_unsigned(a3_h, 5) when view_mode = "11" else to_unsigned(0, 5);
    disp_mm <= to_unsigned(a1_m, 6) when view_mode = "01" else to_unsigned(a2_m, 6) when view_mode = "10" else to_unsigned(a3_m, 6) when view_mode = "11" else to_unsigned(0, 6);

    al1_h <= to_unsigned(a1_h, 5); al1_m <= to_unsigned(a1_m, 6);
    al2_h <= to_unsigned(a2_h, 5); al2_m <= to_unsigned(a2_m, 6);
    al3_h <= to_unsigned(a3_h, 5); al3_m <= to_unsigned(a3_m, 6);

end architecture;
