----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtech Kudela
-- @copyright (c) 2026 Vojtech Kudela, MIT license
-- 
-- Create Date: 23.04.2026 19:42:37
-- Design Name: button_sync
-- Module Name: button_sync - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module instantiates five debounce units to filter
-- mechanical bounces from the directional and center 
-- buttons. It provides clean, synchronized signals for
-- the internal logic of the alarm clock. 
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
    port (
        clk    : in  std_logic; -- Main system clock
        rst    : in  std_logic; -- High-active synchronous reset
        
        -- Raw button inputs from FPGA pins
        btnU   : in  std_logic; -- Raw Up button
        btnD   : in  std_logic; -- Raw Down button
        btnL   : in  std_logic; -- Raw Left button
        btnR   : in  std_logic; -- Raw Right button
        btnC   : in  std_logic; -- Raw Center button
        
        -- Cleaned (debounced) outputs for internal logic
        cleanU : out std_logic; -- Debounced Up signal
        cleanD : out std_logic; -- Debounced Down signal
        cleanL : out std_logic; -- Debounced Left signal
        cleanR : out std_logic; -- Debounced Right signal
        cleanC : out std_logic  -- Debounced Center signal
    );
end entity button_sync;

-------------------------------------------------
-- Button Sync Architecture
architecture Behavioral of button_sync is

    component debounce
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            btn_in     : in  std_logic;
            btn_state  : out std_logic;
            btn_press  : out std_logic
        );
    end component;
    
begin

    -------------------------------------------------
    -- Debouncer Instances
    -- Each instance filters one physical button input.
    -- The 'btn_press' port is left open as only the 
    -- steady state is required for this design.
    -------------------------------------------------

    -- Up button debouncer
    DEB_U : debounce 
        port map (
            clk        => clk,
            rst        => rst,
            btn_in     => btnU,
            btn_state  => cleanU,
            btn_press  => open -- Edge detection pulse not used here
        );
        
    -- Down button debouncer instance
    DEB_D : debounce 
        port map (
            clk        => clk,
            rst        => rst,
            btn_in     => btnD,
            btn_state  => cleanD,
            btn_press  => open -- Edge detection pulse not used here
        );
    
    -- Left button debouncer instance
    DEB_L : debounce 
        port map (
            clk        => clk,
            rst        => rst,
            btn_in     => btnL,
            btn_state  => cleanL,
            btn_press  => open -- Edge detection pulse not used here
        );
    
    -- Right button debouncer instance
    DEB_R : debounce 
        port map (
            clk        => clk,
            rst        => rst,
            btn_in     => btnR,
            btn_state  => cleanR,
            btn_press  => open -- Edge detection pulse not used here
        );
    
    -- Center button debouncer instance
    DEB_C : debounce 
        port map (
            clk        => clk,
            rst        => rst,
            btn_in     => btnC,
            btn_state  => cleanC,
            btn_press  => open -- Edge detection pulse not used here
        );

end Behavioral;