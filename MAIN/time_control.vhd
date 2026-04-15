----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 21:30:39
-- Design Name: 
-- Module Name: time_control - Behavioral
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

entity time_control is
    Port (
        but_00 : in  std_logic;  -- UP
        but_01 : in  std_logic;  -- DOWN
        rst    : in  std_logic;
        clk    : in  std_logic;

        mode       : out std_logic_vector(2 downto 0);
        change     : out std_logic;
        set_enable : out std_logic
    );
end entity;

architecture Behavioral of time_control is

    ------------------------------------------------------------
    -- debounce
    ------------------------------------------------------------
    component debounce
        generic (
            C_SHIFT_LEN : positive := 4;
            C_MAX       : positive := 200_000
        );
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            btn_in    : in  std_logic;
            btn_state : out std_logic;
            btn_press : out std_logic
        );
    end component;

    ------------------------------------------------------------
    -- internal signals
    ------------------------------------------------------------
    signal sig_up_press   : std_logic;
    signal sig_down_press : std_logic;
    signal mode_int       : std_logic_vector(2 downto 0) := "000";

begin

    ------------------------------------------------------------
    -- UP debounce
    ------------------------------------------------------------
    DEB_UP : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => but_00,
            btn_state => open,
            btn_press => sig_up_press
        );

    ------------------------------------------------------------
    -- DOWN debounce
    ------------------------------------------------------------
    DEB_DOWN : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => but_01,
            btn_state => open,
            btn_press => sig_down_press
        );

    ------------------------------------------------------------
    -- SIMPLE MODE LOGIC (temporary)
    ------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mode_int <= "000";
            else

                -- jednoduché pøepínání režimu
                if sig_up_press = '1' then
                    mode_int <= std_logic_vector(unsigned(mode_int) + 1);
                elsif sig_down_press = '1' then
                    mode_int <= std_logic_vector(unsigned(mode_int) - 1);
                end if;

            end if;
        end if;
    end process;

    ------------------------------------------------------------
    -- OUTPUTS
    ------------------------------------------------------------
    mode <= mode_int;

    change <= sig_up_press or sig_down_press;

    -- pøíklad: povol nastavení jen v režimu 3
    set_enable <= '1' when mode_int = "011" else '0';

end architecture;