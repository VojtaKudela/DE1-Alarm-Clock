----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 19:42:37
-- Design Name: 
-- Module Name: button_sync - Behavioral
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

entity button_sync is
    port (clk    : in  std_logic;
          rst    : in  std_logic;
          btnU   : in  std_logic;
          btnD   : in  std_logic;
          btnL   : in  std_logic;
          btnR   : in  std_logic;
          btnC   : in  std_logic;
          cleanU : out std_logic;
          cleanD : out std_logic;
          cleanL : out std_logic;
          cleanR : out std_logic;
          cleanC : out std_logic
          );
          
end entity button_sync;

architecture Behavioral of button_sync is
begin

    -- Tady jsme schovali všech 5 debouncerù pod "jednu støechu"
    DEB_U : entity work.debounce 
        port map(clk       => clk, 
                 rst       => rst, 
                 btn_in    => btnU, 
                 btn_state => cleanU, 
                 btn_press => open
                 );
        
    DEB_D : entity work.debounce 
        port map(clk       => clk, 
                 rst       => rst, 
                 btn_in    => btnD, 
                 btn_state => cleanD, 
                 btn_press => open);
    
    DEB_L : entity work.debounce 
        port map(clk       => clk, 
                 rst       => rst, 
                 btn_in    => btnL, 
                 btn_state => cleanL, 
                 btn_press => open);
    
    DEB_R : entity work.debounce 
        port map(clk       => clk, 
                 rst       => rst, 
                 btn_in    => btnR, 
                 btn_state => cleanR, 
                 btn_press => open);
    
    DEB_C : entity work.debounce 
        port map(clk       => clk, 
                 rst       => rst, 
                 btn_in    => btnC, 
                 btn_state => cleanC, 
                 btn_press => open);

end Behavioral;