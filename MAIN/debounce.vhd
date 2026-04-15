----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2026 17:09:55
-- Design Name: 
-- Module Name: debounce - Behavioral
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

entity debounce is
    generic (
        C_SHIFT_LEN : positive := 4;
        C_MAX       : positive := 1_000_000  -- ~10 ms @ 100 MHz
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        btn_in    : in  std_logic;
        btn_state : out std_logic;  -- stable button state
        btn_press : out std_logic   -- 1-cycle pulse on press
    );
end entity debounce;

architecture Behavioral of debounce is

    -- clock enable generator component
    component clk_en
        generic ( G_MAX : positive );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component;

    -- synchronizer registers
    signal sync0, sync1 : std_logic := '0';

    -- shift register for filtering
    signal shift_reg : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');

    -- debounced signal and its delayed version
    signal debounced   : std_logic := '0';
    signal debounced_d : std_logic := '0';

    -- clock enable signal
    signal ce_sample : std_logic;

    -- constants for stable detection
    constant ALL_ONES  : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '1');
    constant ALL_ZEROS : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');

begin

    --------------------------------------------------------------------
    -- Clock enable instance (sampling rate control)
    --------------------------------------------------------------------
    clk_en_inst : clk_en
        generic map (
            G_MAX => C_MAX
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => ce_sample
        );

    --------------------------------------------------------------------
    -- Debounce logic
    --------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                -- reset all registers
                sync0       <= '0';
                sync1       <= '0';
                shift_reg   <= (others => '0');
                debounced   <= '0';
                debounced_d <= '0';

            else
                -- 2-flip-flop synchronizer (metastability protection)
                sync0 <= btn_in;
                sync1 <= sync0;

                -- sample only when enabled
                if ce_sample = '1' then

                    -- shift in new sample
                    shift_reg <= shift_reg(C_SHIFT_LEN-2 downto 0) & sync1;

                    -- detect stable HIGH state
                    if shift_reg = ALL_ONES then
                        debounced <= '1';

                    -- detect stable LOW state
                    elsif shift_reg = ALL_ZEROS then
                        debounced <= '0';
                    end if;

                end if;

                -- store previous state for edge detection
                debounced_d <= debounced;

            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Output assignment
    --------------------------------------------------------------------
    btn_state <= debounced;                 -- stable level output
    btn_press <= debounced and not debounced_d;  -- rising edge pulse

end architecture;
