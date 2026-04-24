----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:16:40
-- Design Name: 
-- Module Name: alarm_system - Behavioral
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

entity alarm_system is
    port (clk       : in std_logic; 
          rst       : in std_logic; 
          ce_1s     : in std_logic;
          btn_up    : in std_logic; 
          btn_down  : in std_logic; 
          btn_stop  : in std_logic;
          view_mode : in std_logic_vector(1 downto 0);
          set_en    : in std_logic;
          set_hh    : in std_logic;
          set_mm    : in std_logic;
          en_al1    : in std_logic;
          en_al2    : in std_logic;
          en_al3    : in std_logic;      
          curr_hh   : in std_logic_vector(4 downto 0);
          curr_mm   : in std_logic_vector(5 downto 0);
          curr_ss   : in std_logic_vector(5 downto 0);        
          alarm_hh  : out std_logic_vector(4 downto 0);
          alarm_mm  : out std_logic_vector(5 downto 0);        
          ringing   : out std_logic;
          led_al1   : out std_logic;
          led_al2   : out std_logic;
          led_al3   : out std_logic
          );
        
end entity;

architecture Behavioral of alarm_system is
    signal sig_al1_h   : unsigned(4 downto 0);
    signal sig_al2_h   : unsigned(4 downto 0);
    signal sig_al3_h   : unsigned(4 downto 0);
    signal sig_al1_m   : unsigned(5 downto 0);
    signal sig_al2_m   : unsigned(5 downto 0);
    signal sig_al3_m   : unsigned(5 downto 0);
    signal sig_disp_hh : unsigned(4 downto 0);
    signal sig_disp_mm : unsigned(5 downto 0);
begin

    MEM : entity work.alarm_memory
        port map (clk       => clk, 
                  rst       => rst,   
                  btn_up    => btn_up, 
                  btn_down  => btn_down,
                  view_mode => view_mode, 
                  set_en    => set_en, 
                  set_hh    => set_hh, 
                  set_mm    => set_mm,
                  disp_hh   => sig_disp_hh, 
                  disp_mm   => sig_disp_mm,
                  al1_h     => sig_al1_h, 
                  al2_h     => sig_al2_h, 
                  al3_h     => sig_al3_h,
                  al1_m     => sig_al1_m, 
                  al2_m     => sig_al2_m, 
                  al3_m     => sig_al3_m
                  );

    CTRL : entity work.alarm_control
        port map (clk      => clk, 
                  rst      => rst, 
                  ce_1s    => ce_1s, 
                  en_al1   => en_al1, 
                  en_al2   => en_al2, 
                  en_al3   => en_al3,
                  btn_stop => btn_stop,
                  curr_hh  => unsigned(curr_hh), 
                  curr_mm  => unsigned(curr_mm), 
                  curr_ss  => unsigned(curr_ss),
                  al1_h    => sig_al1_h, 
                  al2_h    => sig_al2_h, 
                  al3_h    => sig_al3_h,
                  al1_m    => sig_al1_m, 
                  al2_m    => sig_al2_m, 
                  al3_m    => sig_al3_m,
                  ringing  => ringing, 
                  led_al1  => led_al1, 
                  led_al2  => led_al2, 
                  led_al3  => led_al3
                  );

    alarm_hh <= std_logic_vector(sig_disp_hh);
    alarm_mm <= std_logic_vector(sig_disp_mm);

end Behavioral;
