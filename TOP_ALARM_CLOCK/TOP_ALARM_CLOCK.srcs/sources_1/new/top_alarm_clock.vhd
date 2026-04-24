----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 17:30:24
-- Design Name: Vojtìch Kudela
-- Module Name: top_alarm_clock - Behavioral
-- Project Name: mode_control
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

entity top_alarm_clock is
    port (
        clk   : in std_logic; rst   : in std_logic;
        btnU  : in std_logic; btnD  : in std_logic;
        btnL  : in std_logic; btnR  : in std_logic; btnC  : in std_logic;  
        sw0   : in std_logic; -- AL1 Enable
        sw1   : in std_logic; -- AL2 Enable
        sw2   : in std_logic; -- AL3 Enable      
        seg   : out std_logic_vector(6 downto 0);
        an    : out std_logic_vector(7 downto 0);
        dp    : out std_logic;
        led   : out std_logic_vector(15 downto 0); buzzer : out std_logic
    );
    
end entity;

architecture Behavioral of top_alarm_clock is

    signal clean_btnU   : std_logic;
    signal clean_btnD   : std_logic;
    signal clean_btnL   : std_logic;
    signal clean_btnR   : std_logic;
    signal clean_btnC   : std_logic;
    signal hh_core      : std_logic_vector(4 downto 0);
    signal hh_alarm     : std_logic_vector(4 downto 0);
    signal mm_core      : std_logic_vector(5 downto 0);
    signal ss_core      : std_logic_vector(5 downto 0);
    signal mm_alarm     : std_logic_vector(5 downto 0);    
    signal ringing      : std_logic;
    signal ce_1s_sig    : std_logic;
    signal led_a1       : std_logic;
    signal led_a2       : std_logic;
    signal led_a3       : std_logic;    
    signal view_sel_sig : std_logic_vector(1 downto 0);
    signal set_en_sig   : std_logic;
    signal set_hh_sig   : std_logic;
    signal set_mm_sig   : std_logic;    

begin

    BTN_SYNC_INST : entity work.button_sync
        port map (clk    => clk, 
                  rst    => rst,
                  btnU   => btnU, 
                  btnD   => btnD, 
                  btnL   => btnL, 
                  btnR   => btnR, 
                  btnC   => btnC,
                  cleanU => clean_btnU, 
                  cleanD => clean_btnD, 
                  cleanL => clean_btnL, 
                  cleanR => clean_btnR, 
                  cleanC => clean_btnC
                  );

    CORE : entity work.time_core
        port map (clk        => clk, 
                  rst        => rst, 
                  btnL       => clean_btnL, 
                  btnR       => clean_btnR, 
                  btn_c      => clean_btnC,
                  btn_up     => clean_btnU, 
                  btn_down   => clean_btnD,
                  HH         => hh_core, 
                  MM         => mm_core, 
                  SS         => ss_core, 
                  ce_1s_out  => ce_1s_sig, 
                  view_mode  => view_sel_sig,
                  set_en_out => set_en_sig, 
                  set_hh_out => set_hh_sig, 
                  set_mm_out => set_mm_sig
        );

    ALARM : entity work.alarm_system
        port map (clk       => clk, 
                  rst       => rst, 
                  ce_1s     => ce_1s_sig,
                  btn_up    => clean_btnU, 
                  btn_down  => clean_btnD, 
                  btn_stop  => clean_btnC,
                  view_mode => view_sel_sig, 
                  set_en    => set_en_sig, 
                  set_hh    => set_hh_sig, 
                  set_mm    => set_mm_sig,
                  en_al1    => sw0, 
                  en_al2    => sw1, 
                  en_al3    => sw2, 
                  curr_hh   => hh_core, 
                  curr_mm   => mm_core, 
                  curr_ss   => ss_core,
                  alarm_hh  => hh_alarm, 
                  alarm_mm  => mm_alarm, 
                  ringing   => ringing, 
                  led_al1   => led_a1, 
                  led_al2   => led_a2, 
                  led_al3   => led_a3
                  );

    DISP : entity work.display_driver
        port map (clk       => clk, 
                  rst       => rst, 
                  curr_hh   => hh_core, 
                  curr_mm   => mm_core, 
                  alarm_hh  => hh_alarm, 
                  alarm_mm  => mm_alarm,
                  view_mode => view_sel_sig, 
                  set_en    => set_en_sig, 
                  seg_o     => seg, 
                  dig_o     => an, 
                  dp_o      => dp
                  );

    buzzer <= ringing; 
    
    led(0) <= led_a1; 
    led(1) <= led_a2;
    led(2) <= led_a3;
    led(15 downto 3) <= (others => '0');

end Behavioral;
