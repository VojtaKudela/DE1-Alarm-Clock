----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:08:47
-- Design Name: 
-- Module Name: time_counter - Behavioral
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
        clk     : in  std_logic;
        rst     : in  std_logic;
        ce      : in  std_logic;  
        set_h   : in  std_logic;  -- Impulz pro posun hodin
        set_m   : in  std_logic;  -- Impulz pro posun minut

        hours   : out integer range 0 to 23;
        minutes : out integer range 0 to 59;
        seconds : out integer range 0 to 59
    );
end entity;

architecture Behavioral of time_counter is
    signal sig_h : integer range 0 to 23 := 0;
    signal sig_m : integer range 0 to 59 := 0;
    signal sig_s : integer range 0 to 59 := 0;
begin
    p_time_counter : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sig_h <= 0; sig_m <= 0; sig_s <= 0;
            else
                -- Uživatelské nastavení (má přednost před během)
                if set_h = '1' then
                    if sig_h = 23 then sig_h <= 0; else sig_h <= sig_h + 1; end if;
                    sig_s <= 0; 
                elsif set_m = '1' then
                    if sig_m = 59 then sig_m <= 0; else sig_m <= sig_m + 1; end if;
                    sig_s <= 0; 
                
                -- Normální běh času (1 Hz tick)
                elsif ce = '1' then
                    if sig_s = 59 then
                        sig_s <= 0;
                        if sig_m = 59 then
                            sig_m <= 0;
                            if sig_h = 23 then sig_h <= 0; else sig_h <= sig_h + 1; end if;
                        else
                            sig_m <= sig_m + 1;
                        end if;
                    else
                        sig_s <= sig_s + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    hours <= sig_h; 
    minutes <= sig_m; 
    seconds <= sig_s;

end Behavioral;
