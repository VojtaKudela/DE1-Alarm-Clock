----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 14:59:15
-- Design Name: 
-- Module Name: mode_control - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mode_control is
    port (clk        : in  std_logic;
          rst        : in  std_logic;
          btn_up     : in  std_logic;
          btn_down   : in  std_logic;
          btn_c      : in  std_logic;   
          mode       : out std_logic_vector(1 downto 0);
          btnc_pulse : out std_logic;
          change     : out std_logic
          );
    
end entity mode_control;

architecture Behavioral of mode_control is

    signal sig_btn_up, sig_btn_down, sig_btn_c : std_logic;
    
begin
    -- Instance debounce pro každé tlačítko
    DEB_UP : entity work.debounce
        port map (clk => clk, 
                  rst => rst, 
                  btn_in => btn_up, 
                  btn_press => sig_btn_up
                  );

    DEB_DOWN : entity work.debounce
        port map (clk => clk, 
                  rst => rst, 
                  btn_in => btn_down, 
                  btn_press => sig_btn_down
                  );

    DEB_C : entity work.debounce
        port map (clk => clk, 
                  rst => rst, 
                  btn_in => btn_c, 
                  btn_press => sig_btn_c
                  );

    -- Čítač módů (přepíná zobrazení)
    MODE_CNT : entity work.up_down_mode_counter
        port map (clk       => clk,
                  rst       => rst,
                  mode_up   => sig_btn_up,
                  mode_down => sig_btn_down,
                  set       => sig_btn_c,
                  mode      => mode,
                  set_pulse => btnc_pulse
                  );

    change <= sig_btn_up or sig_btn_down or sig_btn_c;

end Behavioral;
