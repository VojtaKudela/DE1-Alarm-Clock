----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Lukáš Katrňák, Vojtěch Kudela
-- Copyright (c) 2026 Lukáš Katrňák, Vojtěch Kudela, MIT license
-- 
-- Create Date: 23.04.2026 15:22:16
-- Design Name: display_driver
-- Module Name: display_driver - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module implements a multiplexed 7-segment display driver.
-- It switches between displaying current time and alarm settings
-- based on the selected view mode. It also handles a blinking
-- decimal point for time indication.
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

entity display_driver is
    port (
        clk       : in  std_logic;                     -- Main system clock
        rst       : in  std_logic;                     -- High-active synchronous reset

        -- Binary time inputs
        curr_hh   : in  std_logic_vector(4 downto 0);  -- Current hours (0-23)
        curr_mm   : in  std_logic_vector(5 downto 0);  -- Current minutes (0-59)

        -- Binary alarm inputs
        alarm_hh  : in  std_logic_vector(4 downto 0);  -- Alarm hours
        alarm_mm  : in  std_logic_vector(5 downto 0);  -- Alarm minutes

        -- Display control
        view_mode : in  std_logic_vector(1 downto 0);  -- Selects time / alarm views
        set_en    : in  std_logic;                     -- Indicates setting mode
        set_hh    : in  std_logic;                     -- Indicates hours setting mode
        set_mm    : in  std_logic;                     -- Indicates minutes setting mode

        -- Physical display outputs
        seg_o     : out std_logic_vector(6 downto 0);  -- Segment lines (a-g)
        dig_o     : out std_logic_vector(7 downto 0);  -- Digit enable lines
        dp_o      : out std_logic                      -- Decimal point
    );
end entity display_driver;

-------------------------------------------------
-- Display Driver Architecture
-------------------------------------------------
architecture Behavioral of display_driver is

    -------------------------------------------------
    -- Component Declarations
    -------------------------------------------------
    component clk_en is
        generic (
            G_MAX : positive                          
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic                       
        );
    end component;

    component cnt_up_down is
        generic (
            g_CNT_WIDTH : natural
        );
        port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            en     : in  std_logic;
            cnt_up : in  std_logic;
            cnt    : out std_logic_vector(g_CNT_WIDTH-1 downto 0)
        );
    end component;

    component bin2seg is
        port (
            clear : in  std_logic;                    
            bin   : in  std_logic_vector(4 downto 0); 
            seg   : out std_logic_vector(6 downto 0)  
        );
    end component;

    -------------------------------------------------
    -- Internal Signals
    -------------------------------------------------
    signal sig_en_2ms       : std_logic;                
    signal sig_en_500ms     : std_logic;                

    signal sig_cnt_3b       : std_logic_vector(2 downto 0); 
    signal sig_hex          : std_logic_vector(4 downto 0); 

    signal d0, d1, d2, d3   : std_logic_vector(4 downto 0);
    signal d4, d5, d6, d7   : std_logic_vector(4 downto 0);

    signal blink_toggle     : std_logic := '0';         
    signal internal_dp_ctrl : std_logic;                

begin

    -------------------------------------------------
    -- 1. Clock Enable Generators
    -------------------------------------------------
    CLK_EN_MUX : clk_en
        generic map (
            G_MAX => 200_000
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => sig_en_2ms
        );

    CLK_EN_BLINK : clk_en
        generic map (
            G_MAX => 50_000_000
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => sig_en_500ms
        );

    -------------------------------------------------
    -- 2. Decimal Point Blinking Logic
    -------------------------------------------------
    p_blink : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                blink_toggle <= '0';                    
            elsif sig_en_500ms = '1' then
                blink_toggle <= not blink_toggle;       
            end if;
        end if;
    end process p_blink;

    internal_dp_ctrl <= blink_toggle
                        when (view_mode = "00" and set_en = '0')
                        else '1';

    -------------------------------------------------
    -- 3. Digit Value Assembly & Setup Blinking
    -------------------------------------------------
    p_digits : process (view_mode, curr_hh, curr_mm, alarm_hh, alarm_mm, set_en, set_hh, set_mm, blink_toggle)
    begin
        -- Default assignment: blank most significant digits
        d7 <= "10000";
        d6 <= "10000";
        d5 <= "10000";
        d4 <= "10000";

        case view_mode is

            -- TIME VIEW: HH:MM
            when "00" =>
                d7 <= "01101";  -- H
                d6 <= "01110";  -- o
                d5 <= "01111";  -- d
                
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_mm)) mod 10, 5));

            -- ALARM 1 VIEW
            when "01" =>
                d7 <= "01010";  -- A
                d6 <= "01011";  -- L
                d5 <= "01100";  -- _
                d4 <= "00001";  -- index

                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));

            -- ALARM 2 VIEW
            when "10" =>
                d7 <= "01010"; 
                d6 <= "01011"; 
                d5 <= "01100"; 
                d4 <= "00010"; 
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));

            -- ALARM 3 VIEW
            when "11" =>
                d7 <= "01010"; 
                d6 <= "01011"; 
                d5 <= "01100"; 
                d4 <= "00011"; 
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));

            -- Fallback safety case
            when others =>
                d3 <= "10000";
                d2 <= "10000";
                d1 <= "10000";
                d0 <= "10000";
        end case;

        -------------------------------------------------
        -- Logic for blinking during time setup
        -- If blink_toggle = 1, the digits are blanked
        -------------------------------------------------
        if set_en = '1' then
            if set_hh = '1' and blink_toggle = '1' then
                d3 <= "10000"; -- Blank tens of hours
                d2 <= "10000"; -- Blank units of hours
            elsif set_mm = '1' and blink_toggle = '1' then
                d1 <= "10000"; -- Blank tens of minutes
                d0 <= "10000"; -- Blank units of minutes
            end if;
        end if;

    end process p_digits;

    -------------------------------------------------
    -- 4. Digit Counter and Segment Decoder
    -------------------------------------------------
    DIGIT_CNT : cnt_up_down
        generic map (
            g_CNT_WIDTH => 3
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => sig_en_2ms,
            cnt_up => '0',           
            cnt    => sig_cnt_3b
        );

    B2S : bin2seg
        port map (
            clear => rst,
            bin   => sig_hex,
            seg   => seg_o
        );

    -------------------------------------------------
    -- 5. Multiplexing Logic
    -------------------------------------------------
    p_mux : process (
        sig_cnt_3b, d0, d1, d2, d3, d4, d5, d6, d7, internal_dp_ctrl
    )
    begin
        case sig_cnt_3b is
            when "111" =>
                sig_hex <= d7; 
                dig_o <= "01111111"; 
                dp_o <= '1';
            when "110" =>
                sig_hex <= d6; 
                dig_o <= "10111111"; 
                dp_o <= '1';
            when "101" =>
                sig_hex <= d5; 
                dig_o <= "11011111"; 
                dp_o <= '1';
            when "100" =>
                sig_hex <= d4; 
                dig_o <= "11101111"; 
                dp_o <= '1';
            when "011" =>
                sig_hex <= d3; 
                dig_o <= "11110111"; 
                dp_o <= '1';
            when "010" =>
                sig_hex <= d2; 
                dig_o <= "11111011";
                dp_o    <= not internal_dp_ctrl;
            when "001" =>
                sig_hex <= d1; 
                dig_o <= "11111101"; 
                dp_o <= '1';
            when others =>
                sig_hex <= d0; 
                dig_o <= "11111110"; 
                dp_o <= '1';
        end case;
    end process p_mux;

end Behavioral;
