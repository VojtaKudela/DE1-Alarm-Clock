----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtìch Kudela
-- @copyright (c) 2025-2026 Vojtìch Kudela, MIT license
-- 
-- Create Date: 23.04.2026 14:56:27
-- Design Name: debounce
-- Module Name: debounce - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module filters out mechanical bounces of a button 
-- using a sampling clock enable and a shift register. 
-- It provides both the steady state and a rising-edge pulse.
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce is
    generic (
        C_SHIFT_LEN : positive := 4;         -- Length of the debounce shift register
        C_MAX       : positive := 1_000_000  -- Sampling period (~10 ms -> 100 MHz)
    );
    port (
        clk         : in  std_logic;         -- Main system clock
        rst         : in  std_logic;         -- High-active synchronous reset
        btn_in      : in  std_logic;         -- Raw button input (asynchronous)
        btn_state   : out std_logic;         -- Current debounced state
        btn_press   : out std_logic          -- Single-cycle pulse on rising edge
    );
end entity debounce;

-------------------------------------------------
-- Button Debouncer Architecture
architecture Behavioral of debounce is

    -- Signals for synchronization (meta-stability protection)
    signal sync0        : std_logic := '0';
    signal sync1        : std_logic := '0';
    
    -- Shift register for debouncing logic
    signal shift_reg    : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');
    
    -- Internal debounced state and its delayed version for edge detection
    signal debounced    : std_logic := '0';
    signal debounced_d  : std_logic := '0';
    
    -- Clock enable for sampling timing
    signal ce_sample    : std_logic;
    
    -- Constants for validation
    constant ALL_ONES   : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '1');
    constant ALL_ZEROS  : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');

begin

    -------------------------------------------------
    -- Clock Enable Generator
    -- Creates a sampling pulse every C_MAX clock cycles
    -------------------------------------------------
    clk_en_inst : entity work.clk_en
        generic map (
            G_MAX => C_MAX
        )
        port map (
            clk => clk, 
            rst => rst, 
            ce  => ce_sample
        );

    -------------------------------------------------
    -- Main Debouncing Process
    -------------------------------------------------
    p_debounce : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all internal registers
                sync0       <= '0';
                sync1       <= '0';
                shift_reg   <= (others => '0');
                debounced   <= '0';
                debounced_d <= '0';
            else
                -- 1. Synchronize input to local clock domain
                sync0 <= btn_in;
                sync1 <= sync0;

                -- 2. Sampling and shift register logic
                if ce_sample = '1' then
                    shift_reg <= shift_reg(C_SHIFT_LEN-2 downto 0) & sync1;
                    
                    -- Check if all bits are identical
                    if shift_reg = ALL_ONES then
                        debounced <= '1';
                    elsif shift_reg = ALL_ZEROS then
                        debounced <= '0';
                    end if;
                end if;

                -- 3. Delay the debounced signal for edge detection
                debounced_d <= debounced;
            end if;
        end if;
    end process p_debounce;

    -------------------------------------------------
    -- Output Assignments
    -------------------------------------------------
    
    -- Continuous state of the button
    btn_state <= debounced;
    
    -- Pulse on rising edge (current is '1', previous was '0')
    btn_press <= debounced and not debounced_d;

end architecture Behavioral;
