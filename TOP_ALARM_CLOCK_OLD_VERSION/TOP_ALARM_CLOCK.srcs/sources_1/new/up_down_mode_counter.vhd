----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:01:40
-- Design Name: 
-- Module Name: up_down_mode_counter - Behavioral
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

entity up_down_mode_counter is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        mode_up    : in  std_logic;
        mode_down  : in  std_logic;
        set        : in  std_logic;
        mode       : out std_logic_vector(1 downto 0);
        set_pulse  : out std_logic
    );
end entity;

architecture Behavioral of up_down_mode_counter is
    signal mode_cnt    : unsigned(1 downto 0) := (others => '0');
    signal mode_up_d   : std_logic := '0';
    signal mode_down_d : std_logic := '0';
    signal set_d       : std_logic := '0';
begin

    set_pulse <= set and not set_d;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mode_cnt <= (others => '0');
                mode_up_d <= '0';
                mode_down_d <= '0';
                set_d <= '0';
            else
                -- Detekce hrany a úprava módu
                if (mode_up = '1' and mode_up_d = '0') then
                    mode_cnt <= mode_cnt + 1;
                end if;

                if (mode_down = '1' and mode_down_d = '0') then
                    mode_cnt <= mode_cnt - 1;
                end if;

                mode_up_d   <= mode_up;
                mode_down_d <= mode_down;
                set_d       <= set;
            end if;
        end if;
    end process;

    mode <= std_logic_vector(mode_cnt);

end Behavioral;
