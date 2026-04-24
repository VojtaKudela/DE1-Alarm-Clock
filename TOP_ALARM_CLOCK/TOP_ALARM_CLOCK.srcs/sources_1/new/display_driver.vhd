----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:22:16
-- Design Name: 
-- Module Name: display_driver - Behavioral
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

entity display_driver is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;

        curr_hh   : in  std_logic_vector(4 downto 0);
        curr_mm   : in  std_logic_vector(5 downto 0);
        alarm_hh  : in  std_logic_vector(4 downto 0);
        alarm_mm  : in  std_logic_vector(5 downto 0);
        view_mode : in  std_logic_vector(1 downto 0);
        
        set_en    : in  std_logic; 

        seg_o     : out std_logic_vector(6 downto 0);
        dig_o     : out std_logic_vector(7 downto 0);
        dp_o      : out std_logic
    );
end entity display_driver;

architecture Structural of display_driver is

    component clk_en is
        generic (G_MAX : positive);
        port (clk : in std_logic; rst : in std_logic; ce : out std_logic);
    end component;

    component cnt_up_down is
        generic (g_CNT_WIDTH : natural);
        port (clk : in std_logic; rst : in std_logic; en : in std_logic; cnt_up : in std_logic; cnt : out std_logic_vector(g_CNT_WIDTH-1 downto 0));
    end component;

    component bin2seg is
        port (clear : in std_logic; bin : in std_logic_vector(4 downto 0); seg : out std_logic_vector(6 downto 0));
    end component;

    signal sig_en_2ms   : std_logic;
    signal sig_en_500ms : std_logic; -- Pulz každou pùl sekundu
    signal sig_cnt_3b   : std_logic_vector(2 downto 0);
    signal sig_hex      : std_logic_vector(4 downto 0);
    signal d0, d1, d2, d3, d4, d5, d6, d7 : std_logic_vector(4 downto 0);

    signal blink_toggle : std_logic := '0';
    signal internal_dp_ctrl : std_logic;

begin

    -- 1. CLOCK ENABLES (2 ms pro multiplex, 500 ms pro blikání teèky)
    CLK_EN_I : clk_en generic map (G_MAX => 200_000) port map (clk => clk, rst => rst, ce => sig_en_2ms);
    
    CLK_EN_BLINK : clk_en generic map (G_MAX => 50_000_000) port map (clk => clk, rst => rst, ce => sig_en_500ms);

    -- 2. LOGIKA BLIKÁNÍ (Pøeklápìní stavu na základì 500ms pulzu)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                blink_toggle <= '0';
            elsif sig_en_500ms = '1' then
                blink_toggle <= not blink_toggle;
            end if;
        end if;
    end process;

    internal_dp_ctrl <= blink_toggle when (view_mode = "00" and set_en = '0') else '1';

    -- 3. SESTAVENÍ ZNAKÙ NA DISPLEJ
    process(view_mode, curr_hh, curr_mm, alarm_hh, alarm_mm)
    begin
        d7 <= "10000"; d6 <= "10000"; d5 <= "10000"; d4 <= "10000"; 
        case view_mode is
            when "00" => 
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_mm)) mod 10, 5));
            when "01" => 
                d7 <= "01010"; d6 <= "01011"; d5 <= "01100"; d4 <= "00001"; 
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));
            when "10" => 
                d7 <= "01010"; d6 <= "01011"; d5 <= "01100"; d4 <= "00010"; 
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));
            when "11" => 
                d7 <= "01010"; d6 <= "01011"; d5 <= "01100"; d4 <= "00011"; 
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));
            when others => d3 <= "10000"; d2 <= "10000"; d1 <= "10000"; d0 <= "10000";
        end case;
    end process;

    -- 4. MULTIPLEXER A ZOBRAZOVÁNÍ
    DIGIT_CNT : cnt_up_down generic map (g_CNT_WIDTH => 3) port map (clk => clk, rst => rst, en => sig_en_2ms, cnt_up => '0', cnt => sig_cnt_3b);
    B2S : bin2seg port map (clear => rst, bin => sig_hex, seg => seg_o);

    p_mux : process (sig_cnt_3b, d0, d1, d2, d3, d4, d5, d6, d7, internal_dp_ctrl)
    begin
        case sig_cnt_3b is
            when "111" => sig_hex <= d7; dig_o <= "01111111"; dp_o <= '1';
            when "110" => sig_hex <= d6; dig_o <= "10111111"; dp_o <= '1';
            when "101" => sig_hex <= d5; dig_o <= "11011111"; dp_o <= '1';
            when "100" => sig_hex <= d4; dig_o <= "11101111"; dp_o <= '1';
            when "011" => sig_hex <= d3; dig_o <= "11110111"; dp_o <= '1';
            when "010" => sig_hex <= d2; dig_o <= "11111011"; dp_o <= not internal_dp_ctrl; 
            when "001" => sig_hex <= d1; dig_o <= "11111101"; dp_o <= '1';
            when others => sig_hex <= d0; dig_o <= "11111110"; dp_o <= '1';
        end case;
    end process;

end architecture Structural;
